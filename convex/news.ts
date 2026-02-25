import { v, ConvexError } from "convex/values";
import { query, mutation } from "./_generated/server";
import { getAuthUserId } from "@convex-dev/auth/server";
import { api } from "./_generated/api";

// Check if user is admin or manager (align with api.authz.isManager logic)
async function requireAdminOrManager(ctx: any) {
  const userId = await getAuthUserId(ctx);
  console.log("news.requireAdminOrManager userId:", userId);

  if (!userId) {
    throw new ConvexError("Nepřihlášen");
  }

  const isManager = await ctx.runQuery(api.authz.isManager, {});
  console.log("news.requireAdminOrManager isManager:", isManager);

  if (!isManager) {
    throw new ConvexError("Pouze pro administrátory a správce");
  }

  return userId;
}

// Get all news articles
export const listArticles = query({
  args: {},
  handler: async (ctx) => {
    const articles = await ctx.db
      .query("newsArticles")
      .withIndex("by_date")
      .order("desc")
      .collect();
    
    // Sort: pinned first, then by date
    return articles.sort((a, b) => {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt - a.createdAt;
    });
  },
});

// Create a new article
export const createArticle = mutation({
  args: {
    title: v.string(),
    content: v.string(),
    summary: v.optional(v.string()),
    isPinned: v.optional(v.boolean()),
  },
  handler: async (ctx, args) => {
    await requireAdminOrManager(ctx);

    const now = Date.now();
    return await ctx.db.insert("newsArticles", {
      title: args.title,
      content: args.content,
      summary: args.summary,
      isPinned: args.isPinned || false,
      createdAt: now,
      updatedAt: now,
    });
  },
});

// Update an article
export const updateArticle = mutation({
  args: {
    id: v.id("newsArticles"),
    title: v.optional(v.string()),
    content: v.optional(v.string()),
    summary: v.optional(v.string()),
    isPinned: v.optional(v.boolean()),
  },
  handler: async (ctx, args) => {
    await requireAdminOrManager(ctx);

    const { id, ...updates } = args;
    const filteredUpdates = Object.fromEntries(
      Object.entries(updates).filter(([, v]) => v !== undefined)
    );
    
    await ctx.db.patch(id, {
      ...filteredUpdates,
      updatedAt: Date.now(),
    });
  },
});

// Delete an article
export const deleteArticle = mutation({
  args: { id: v.id("newsArticles") },
  handler: async (ctx, args) => {
    await requireAdminOrManager(ctx);

    await ctx.db.delete(args.id);
  },
});

// Toggle pin status
export const togglePin = mutation({
  args: { id: v.id("newsArticles") },
  handler: async (ctx, args) => {
    await requireAdminOrManager(ctx);

    const article = await ctx.db.get(args.id);
    if (!article) throw new ConvexError("Článek nenalezen");

    await ctx.db.patch(args.id, {
      isPinned: !article.isPinned,
      updatedAt: Date.now(),
    });
  },
});
