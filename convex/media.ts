import { mutation, query } from "./_generated/server";
import { v } from "convex/values";
import { getAuthUserId } from "@convex-dev/auth/server";

// Generate random 5-char code
function generateShortCode(): string {
  const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
  let code = "";
  for (let i = 0; i < 5; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

// Generate upload URL for file storage
export const generateUploadUrl = mutation({
  args: {},
  handler: async (ctx) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) {
      throw new Error("Nepřihlášen");
    }
    return await ctx.storage.generateUploadUrl();
  },
});

// Get public URL for a stored image
export const getImageUrl = query({
  args: { storageId: v.id("_storage") },
  handler: async (ctx, args) => {
    return await ctx.storage.getUrl(args.storageId);
  },
});

// Get URL for a storage ID (mutation version - can be called after upload)
export const getStorageUrl = mutation({
  args: { storageId: v.string() },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) {
      throw new Error("Nepřihlášen");
    }
    // Use the storage ID directly - Convex handles the conversion
    return await ctx.storage.getUrl(args.storageId as any);
  },
});

// Get multiple image URLs at once
export const getImageUrls = query({
  args: { storageIds: v.array(v.id("_storage")) },
  handler: async (ctx, args) => {
    const urls = await Promise.all(
      args.storageIds.map(async (storageId) => {
        const url = await ctx.storage.getUrl(storageId);
        return { storageId, url };
      })
    );
    return urls;
  },
});

// Delete a stored image
export const deleteImage = mutation({
  args: { storageId: v.id("_storage") },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) {
      throw new Error("Nepřihlášen");
    }
    await ctx.storage.delete(args.storageId);
    return { ok: true };
  },
});

// Create a 5-char shortcode for a storage ID
export const createShortcode = mutation({
  args: { storageId: v.id("_storage") },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) {
      throw new Error("Nepřihlášen");
    }
    
    // Generate unique code
    let code = generateShortCode();
    let existing = await ctx.db
      .query("imageShortcodes")
      .withIndex("by_code", (q) => q.eq("code", code))
      .first();
    
    // Retry if collision (very unlikely)
    while (existing) {
      code = generateShortCode();
      existing = await ctx.db
        .query("imageShortcodes")
        .withIndex("by_code", (q) => q.eq("code", code))
        .first();
    }
    
    await ctx.db.insert("imageShortcodes", {
      code,
      storageId: args.storageId,
      createdAt: Date.now(),
    });
    
    return code;
  },
});

// Get storage URL by shortcode
export const getByShortcode = query({
  args: { code: v.string() },
  handler: async (ctx, args) => {
    const shortcode = await ctx.db
      .query("imageShortcodes")
      .withIndex("by_code", (q) => q.eq("code", args.code))
      .first();
    
    if (!shortcode) {
      return null;
    }
    
    return await ctx.storage.getUrl(shortcode.storageId);
  },
});
