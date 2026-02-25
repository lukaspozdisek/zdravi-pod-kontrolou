import { v } from "convex/values";
import { query, mutation } from "./_generated/server";
import { getAuthUserId } from "@convex-dev/auth/server";
import { api } from "./_generated/api";

// Check if user is admin or manager (align with api.authz.isManager logic)
async function requireAdminOrManager(ctx: any) {
  const userId = await getAuthUserId(ctx);
  console.log("biohack.requireAdminOrManager userId:", userId);

  if (!userId) {
    throw new Error("Nepřihlášen");
  }

  const isManager = await ctx.runQuery(api.authz.isManager, {});
  console.log("biohack.requireAdminOrManager isManager:", isManager);

  if (!isManager) {
    throw new Error("Pouze pro administrátory a správce");
  }

  return userId;
}

// ============ CATEGORIES ============

export const getCategories = query({
  args: {},
  handler: async (ctx) => {
    const categories = await ctx.db
      .query("biohackCategories")
      .withIndex("by_order")
      .collect();
    return categories;
  },
});

export const createCategory = mutation({
  args: {
    name: v.string(),
    description: v.optional(v.string()),
    icon: v.optional(v.string()),
    color: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    await requireAdminOrManager(ctx);
    
    // Get highest order
    const categories = await ctx.db.query("biohackCategories").collect();
    const maxOrder = categories.length > 0 
      ? Math.max(...categories.map(c => c.order)) 
      : -1;
    
    const now = Date.now();
    
    // Random color if not specified
    const colors = ["blue", "emerald", "amber", "red", "purple", "lime", "cyan", "orange"];
    const randomColor = colors[Math.floor(Math.random() * colors.length)];
    
    const id = await ctx.db.insert("biohackCategories", {
      name: args.name,
      description: args.description,
      icon: args.icon || "Leaf",
      color: args.color || randomColor,
      order: maxOrder + 1,
      createdAt: now,
      updatedAt: now,
    });
    
    return { ok: true, id };
  },
});

export const updateCategory = mutation({
  args: {
    id: v.id("biohackCategories"),
    name: v.optional(v.string()),
    description: v.optional(v.string()),
    icon: v.optional(v.string()),
    color: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    await requireAdminOrManager(ctx);
    
    const { id, ...updates } = args;
    const filtered: Record<string, any> = { updatedAt: Date.now() };
    
    if (updates.name !== undefined) filtered.name = updates.name;
    if (updates.description !== undefined) filtered.description = updates.description;
    if (updates.icon !== undefined) filtered.icon = updates.icon;
    if (updates.color !== undefined) filtered.color = updates.color;
    
    await ctx.db.patch(id, filtered);
    return { ok: true };
  },
});

export const deleteCategory = mutation({
  args: { id: v.id("biohackCategories") },
  handler: async (ctx, args) => {
    await requireAdminOrManager(ctx);
    
    // Delete all topics and articles in this category
    const topics = await ctx.db
      .query("biohackTopics")
      .withIndex("by_category", (q) => q.eq("categoryId", args.id))
      .collect();
    
    for (const topic of topics) {
      const articles = await ctx.db
        .query("biohackArticles")
        .withIndex("by_topic", (q) => q.eq("topicId", topic._id))
        .collect();
      
      for (const article of articles) {
        await ctx.db.delete(article._id);
      }
      await ctx.db.delete(topic._id);
    }
    
    await ctx.db.delete(args.id);
    return { ok: true };
  },
});

export const reorderCategories = mutation({
  args: {
    categoryIds: v.array(v.id("biohackCategories")),
  },
  handler: async (ctx, args) => {
    await requireAdminOrManager(ctx);
    
    for (let i = 0; i < args.categoryIds.length; i++) {
      await ctx.db.patch(args.categoryIds[i], { 
        order: i,
        updatedAt: Date.now(),
      });
    }
    
    return { ok: true };
  },
});

// ============ TOPICS ============

export const getTopics = query({
  args: { categoryId: v.id("biohackCategories") },
  handler: async (ctx, args) => {
    const topics = await ctx.db
      .query("biohackTopics")
      .withIndex("by_category_order", (q) => q.eq("categoryId", args.categoryId))
      .collect();
    return topics;
  },
});

export const createTopic = mutation({
  args: {
    categoryId: v.id("biohackCategories"),
    name: v.string(),
    description: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    await requireAdminOrManager(ctx);
    
    // Get highest order in category
    const topics = await ctx.db
      .query("biohackTopics")
      .withIndex("by_category", (q) => q.eq("categoryId", args.categoryId))
      .collect();
    const maxOrder = topics.length > 0 
      ? Math.max(...topics.map(t => t.order)) 
      : -1;
    
    const now = Date.now();
    const id = await ctx.db.insert("biohackTopics", {
      categoryId: args.categoryId,
      name: args.name,
      description: args.description,
      order: maxOrder + 1,
      createdAt: now,
      updatedAt: now,
    });
    
    return { ok: true, id };
  },
});

export const updateTopic = mutation({
  args: {
    id: v.id("biohackTopics"),
    name: v.optional(v.string()),
    description: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    await requireAdminOrManager(ctx);
    
    const { id, ...updates } = args;
    const filtered: Record<string, any> = { updatedAt: Date.now() };
    
    if (updates.name !== undefined) filtered.name = updates.name;
    if (updates.description !== undefined) filtered.description = updates.description;
    
    await ctx.db.patch(id, filtered);
    return { ok: true };
  },
});

export const deleteTopic = mutation({
  args: { id: v.id("biohackTopics") },
  handler: async (ctx, args) => {
    await requireAdminOrManager(ctx);
    
    // Delete all articles in this topic
    const articles = await ctx.db
      .query("biohackArticles")
      .withIndex("by_topic", (q) => q.eq("topicId", args.id))
      .collect();
    
    for (const article of articles) {
      await ctx.db.delete(article._id);
    }
    
    await ctx.db.delete(args.id);
    return { ok: true };
  },
});

// ============ ARTICLES ============

export const getArticles = query({
  args: { topicId: v.id("biohackTopics") },
  handler: async (ctx, args) => {
    const articles = await ctx.db
      .query("biohackArticles")
      .withIndex("by_topic_order", (q) => q.eq("topicId", args.topicId))
      .collect();
    return articles;
  },
});

export const getArticle = query({
  args: { id: v.id("biohackArticles") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  },
});

export const createArticle = mutation({
  args: {
    topicId: v.id("biohackTopics"),
    title: v.string(),
    content: v.string(),
    summary: v.optional(v.string()),
    isPremium: v.optional(v.boolean()),
    images: v.optional(v.array(v.id("_storage"))),
  },
  handler: async (ctx, args) => {
    await requireAdminOrManager(ctx);
    
    // Get highest order in topic
    const articles = await ctx.db
      .query("biohackArticles")
      .withIndex("by_topic", (q) => q.eq("topicId", args.topicId))
      .collect();
    const maxOrder = articles.length > 0 
      ? Math.max(...articles.map(a => a.order)) 
      : -1;
    
    const now = Date.now();
    const id = await ctx.db.insert("biohackArticles", {
      topicId: args.topicId,
      title: args.title,
      content: args.content,
      summary: args.summary,
      isPremium: args.isPremium,
      images: args.images,
      order: maxOrder + 1,
      createdAt: now,
      updatedAt: now,
    });
    
    return { ok: true, id };
  },
});

export const updateArticle = mutation({
  args: {
    id: v.id("biohackArticles"),
    title: v.optional(v.string()),
    content: v.optional(v.string()),
    summary: v.optional(v.string()),
    isPremium: v.optional(v.boolean()),
    images: v.optional(v.array(v.id("_storage"))),
  },
  handler: async (ctx, args) => {
    await requireAdminOrManager(ctx);
    
    const { id, ...updates } = args;
    const filtered: Record<string, any> = { updatedAt: Date.now() };
    
    if (updates.title !== undefined) filtered.title = updates.title;
    if (updates.content !== undefined) filtered.content = updates.content;
    if (updates.summary !== undefined) filtered.summary = updates.summary;
    if (updates.isPremium !== undefined) filtered.isPremium = updates.isPremium;
    if (updates.images !== undefined) filtered.images = updates.images;
    
    await ctx.db.patch(id, filtered);
    return { ok: true };
  },
});

export const deleteArticle = mutation({
  args: { id: v.id("biohackArticles") },
  handler: async (ctx, args) => {
    await requireAdminOrManager(ctx);
    await ctx.db.delete(args.id);
    return { ok: true };
  },
});

// ============ FULL DATA FOR DISPLAY ============

export const getFullBiohackData = query({
  args: {},
  handler: async (ctx) => {
    const categories = await ctx.db
      .query("biohackCategories")
      .withIndex("by_order")
      .collect();
    
    const result = await Promise.all(categories.map(async (category) => {
      const topics = await ctx.db
        .query("biohackTopics")
        .withIndex("by_category_order", (q) => q.eq("categoryId", category._id))
        .collect();
      
      const topicsWithArticles = await Promise.all(topics.map(async (topic) => {
        const articles = await ctx.db
          .query("biohackArticles")
          .withIndex("by_topic_order", (q) => q.eq("topicId", topic._id))
          .collect();
        
        return {
          ...topic,
          articles,
        };
      }));
      
      return {
        ...category,
        topics: topicsWithArticles,
      };
    }));
    
    return result;
  },
});
