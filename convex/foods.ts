import { mutation, query } from "./_generated/server";
import { v } from "convex/values";
import { getAuthUserId } from "@convex-dev/auth/server";

// Check if user is admin/manager
async function requireAdminOrManager(ctx: any) {
  const userId = await getAuthUserId(ctx);
  if (!userId) {
    throw new Error("Nepřihlášen");
  }
  const user = await ctx.db.get(userId);
  if (!user || !["admin", "manager"].includes(user.role || "")) {
    throw new Error("Nedostatečná oprávnění");
  }
  return userId;
}

// Get all custom foods
export const getAll = query({
  args: {},
  handler: async (ctx) => {
    const foods = await ctx.db
      .query("customFoods")
      .order("desc")
      .collect();
    
    // Get image URLs
    const foodsWithUrls = await Promise.all(
      foods.map(async (food) => {
        let imageUrl: string | null = null;
        if (food.imageId) {
          imageUrl = await ctx.storage.getUrl(food.imageId);
        }
        return { ...food, imageUrl };
      })
    );
    
    return foodsWithUrls;
  },
});

// Get active custom foods by tab
export const getByTab = query({
  args: { tabId: v.string() },
  handler: async (ctx, args) => {
    const foods = await ctx.db
      .query("customFoods")
      .withIndex("by_tab", (q) => q.eq("tabId", args.tabId))
      .collect();
    
    // Filter active and get image URLs
    const activeFoods = await Promise.all(
      foods
        .filter((f) => f.isActive !== false)
        .map(async (food) => {
          let imageUrl: string | null = null;
          if (food.imageId) {
            imageUrl = await ctx.storage.getUrl(food.imageId);
          }
          return { ...food, imageUrl };
        })
    );
    
    return activeFoods;
  },
});

// Get all active custom foods grouped by tab and category
export const getAllActive = query({
  args: {},
  handler: async (ctx) => {
    const foods = await ctx.db
      .query("customFoods")
      .collect();
    
    // Filter active and get image URLs
    const activeFoods = await Promise.all(
      foods
        .filter((f) => f.isActive !== false)
        .map(async (food) => {
          let imageUrl: string | null = null;
          if (food.imageId) {
            imageUrl = await ctx.storage.getUrl(food.imageId);
          }
          return { ...food, imageUrl };
        })
    );
    
    return activeFoods;
  },
});

// Create custom food
export const create = mutation({
  args: {
    name: v.string(),
    detail: v.string(),
    protein: v.number(),
    carbs: v.number(),
    sugars: v.optional(v.number()),
    fiber: v.number(),
    kcal: v.number(),
    icon: v.string(),
    imageId: v.optional(v.id("_storage")),
    tabId: v.string(),
    categoryName: v.string(),
  },
  handler: async (ctx, args) => {
    await requireAdminOrManager(ctx);
    
    // Get max order for this tab+category
    const existing = await ctx.db
      .query("customFoods")
      .withIndex("by_tab_category", (q) => 
        q.eq("tabId", args.tabId).eq("categoryName", args.categoryName)
      )
      .collect();
    const maxOrder = existing.length > 0 
      ? Math.max(...existing.map((f) => f.order)) + 1 
      : 0;
    
    const now = Date.now();
    const id = await ctx.db.insert("customFoods", {
      name: args.name,
      detail: args.detail,
      protein: args.protein,
      carbs: args.carbs,
      sugars: args.sugars,
      fiber: args.fiber,
      kcal: args.kcal,
      icon: args.icon,
      imageId: args.imageId,
      tabId: args.tabId,
      categoryName: args.categoryName,
      order: maxOrder,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    });
    
    return { ok: true, id };
  },
});

// Update custom food
export const update = mutation({
  args: {
    id: v.id("customFoods"),
    name: v.optional(v.string()),
    detail: v.optional(v.string()),
    protein: v.optional(v.number()),
    carbs: v.optional(v.number()),
    sugars: v.optional(v.number()),
    fiber: v.optional(v.number()),
    kcal: v.optional(v.number()),
    icon: v.optional(v.string()),
    imageId: v.optional(v.id("_storage")),
    tabId: v.optional(v.string()),
    categoryName: v.optional(v.string()),
    isActive: v.optional(v.boolean()),
  },
  handler: async (ctx, args) => {
    await requireAdminOrManager(ctx);
    
    const { id, ...updates } = args;
    const food = await ctx.db.get(id);
    if (!food) {
      throw new Error("Potravina nenalezena");
    }
    
    await ctx.db.patch(id, {
      ...updates,
      updatedAt: Date.now(),
    });
    
    return { ok: true };
  },
});

// Delete custom food (soft delete)
export const remove = mutation({
  args: { id: v.id("customFoods") },
  handler: async (ctx, args) => {
    await requireAdminOrManager(ctx);
    
    await ctx.db.patch(args.id, {
      isActive: false,
      updatedAt: Date.now(),
    });
    
    return { ok: true };
  },
});

// Hard delete custom food
export const hardDelete = mutation({
  args: { id: v.id("customFoods") },
  handler: async (ctx, args) => {
    await requireAdminOrManager(ctx);
    
    const food = await ctx.db.get(args.id);
    if (food?.imageId) {
      await ctx.storage.delete(food.imageId);
    }
    
    await ctx.db.delete(args.id);
    
    return { ok: true };
  },
});

// =============================================
// USER CUSTOM FOODS - Personal food items
// =============================================

// Get user's custom foods
export const getUserFoods = query({
  args: {},
  handler: async (ctx) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) return [];
    
    const foods = await ctx.db
      .query("userCustomFoods")
      .withIndex("by_user", (q) => q.eq("userId", userId))
      .order("desc")
      .collect();
    
    // Get image URLs
    const foodsWithUrls = await Promise.all(
      foods.map(async (food) => {
        let imageUrl: string | null = null;
        if (food.imageId) {
          imageUrl = await ctx.storage.getUrl(food.imageId);
        }
        return { ...food, imageUrl };
      })
    );
    
    return foodsWithUrls;
  },
});

// Create user's custom food
export const createUserFood = mutation({
  args: {
    name: v.string(),
    detail: v.string(),
    protein: v.number(),
    carbs: v.number(),
    sugars: v.optional(v.number()),
    fiber: v.number(),
    kcal: v.number(),
    icon: v.optional(v.string()),
    imageId: v.optional(v.id("_storage")),
  },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) {
      throw new Error("Nepřihlášen");
    }
    
    const id = await ctx.db.insert("userCustomFoods", {
      userId,
      name: args.name,
      detail: args.detail,
      protein: args.protein,
      carbs: args.carbs,
      sugars: args.sugars,
      fiber: args.fiber,
      kcal: args.kcal,
      icon: args.icon,
      imageId: args.imageId,
      createdAt: Date.now(),
    });
    
    return { ok: true, id };
  },
});

// Update user's custom food
export const updateUserFood = mutation({
  args: {
    id: v.id("userCustomFoods"),
    name: v.optional(v.string()),
    detail: v.optional(v.string()),
    protein: v.optional(v.number()),
    carbs: v.optional(v.number()),
    sugars: v.optional(v.number()),
    fiber: v.optional(v.number()),
    kcal: v.optional(v.number()),
    icon: v.optional(v.string()),
    imageId: v.optional(v.id("_storage")),
  },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) {
      throw new Error("Nepřihlášen");
    }
    
    const user = await ctx.db.get(userId);
    const isAdminOrManager = user && ["admin", "manager"].includes(user.role || "");
    
    const food = await ctx.db.get(args.id);
    if (!food) {
      throw new Error("Potravina nenalezena");
    }
    
    // Allow if owner OR admin/manager
    if (food.userId !== userId && !isAdminOrManager) {
      throw new Error("Nemáte oprávnění upravit tuto potravinu");
    }
    
    const { id, ...updates } = args;
    
    // If new image is being uploaded, delete old one
    if (updates.imageId && food.imageId && updates.imageId !== food.imageId) {
      await ctx.storage.delete(food.imageId);
    }
    
    await ctx.db.patch(id, updates);
    
    return { ok: true };
  },
});

// Delete user's custom food
export const deleteUserFood = mutation({
  args: { id: v.id("userCustomFoods") },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) {
      throw new Error("Nepřihlášen");
    }
    
    const user = await ctx.db.get(userId);
    const isAdminOrManager = user && ["admin", "manager"].includes(user.role || "");
    
    const food = await ctx.db.get(args.id);
    if (!food) {
      throw new Error("Potravina nenalezena");
    }
    
    // Allow if owner OR admin/manager
    if (food.userId !== userId && !isAdminOrManager) {
      throw new Error("Nemáte oprávnění smazat tuto potravinu");
    }
    
    // Delete image from storage if exists
    if (food.imageId) {
      await ctx.storage.delete(food.imageId);
    }
    
    await ctx.db.delete(args.id);
    
    return { ok: true };
  },
});
