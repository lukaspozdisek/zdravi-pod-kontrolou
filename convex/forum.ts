import { v } from "convex/values";
import { query, mutation } from "./_generated/server";
import { getAuthUserId } from "@convex-dev/auth/server";

// Get all topics (posts without parent)
export const getTopics = query({
  args: {
    category: v.optional(v.string()),
    filter: v.optional(v.string()), // "new", "pinned", "my-posts"
  },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) return [];

    // Check if user is admin/moderator
    const currentUser = await ctx.db.get(userId);
    const isAdmin = currentUser?.role === "admin" || currentUser?.role === "manager" || currentUser?.role === "moderator";

    let topics = await ctx.db
      .query("forumPosts")
      .withIndex("by_created")
      .filter((q) => q.eq(q.field("parentId"), undefined))
      .order("desc")
      .collect();

    // Apply category filter
    if (args.category && !["new", "updated", "my-posts", "pinned", "all"].includes(args.category)) {
      topics = topics.filter((t) => t.category === args.category);
    }

    // Apply special filters
    if (args.filter === "new") {
      const oneDayAgo = Date.now() - 24 * 60 * 60 * 1000;
      topics = topics.filter((t) => t.createdAt > oneDayAgo);
    } else if (args.filter === "pinned") {
      topics = topics.filter((t) => t.isPinned);
    } else if (args.filter === "my-posts") {
      topics = topics.filter((t) => t.userId === userId);
    } else if (args.filter === "updated") {
      // Sort by updatedAt instead
      topics = topics.sort((a, b) => b.updatedAt - a.updatedAt).slice(0, 10);
    }

    // Get reply counts for each topic
    const topicsWithCounts = await Promise.all(
      topics.map(async (topic) => {
        const replies = await ctx.db
          .query("forumPosts")
          .withIndex("by_parent", (q) => q.eq("parentId", topic._id))
          .collect();
        
        const isNew = topic.createdAt > Date.now() - 24 * 60 * 60 * 1000;
        const isMine = topic.userId === userId;

        return {
          ...topic,
          replyCount: replies.length,
          views: topic.views ?? 0,
          isNew,
          isMine,
          isAdmin,
        };
      })
    );

    return topicsWithCounts;
  },
});

// Get replies for a topic
export const getReplies = query({
  args: { topicId: v.id("forumPosts") },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) return [];

    // Check if user is admin/moderator
    const currentUser = await ctx.db.get(userId);
    const isAdmin = currentUser?.role === "admin" || currentUser?.role === "manager" || currentUser?.role === "moderator";

    const replies = await ctx.db
      .query("forumPosts")
      .withIndex("by_parent", (q) => q.eq("parentId", args.topicId))
      .order("asc")
      .collect();

    return replies.map((reply) => ({
      ...reply,
      isMine: reply.userId === userId,
      isAdmin,
      likeCount: reply.likedBy?.length ?? 0,
      isLikedByMe: reply.likedBy?.includes(userId) ?? false,
    }));
  },
});

// Get a single topic
export const getTopic = query({
  args: { topicId: v.id("forumPosts") },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) return null;

    const topic = await ctx.db.get(args.topicId);
    if (!topic || topic.parentId) return null;

    // Check if user is admin/moderator
    const user = await ctx.db.get(userId);
    const isAdmin = user?.role === "admin" || user?.role === "manager" || user?.role === "moderator";

    return {
      ...topic,
      isMine: topic.userId === userId,
      isAdmin,
      likeCount: topic.likedBy?.length ?? 0,
      isLikedByMe: topic.likedBy?.includes(userId) ?? false,
    };
  },
});

// Create a new topic
export const createTopic = mutation({
  args: {
    category: v.string(),
    title: v.string(),
    text: v.string(),
  },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Not authenticated");

    const user = await ctx.db.get(userId);
    if (!user) throw new Error("User not found");

    const now = Date.now();
    const authorName = user.name || user.email?.split("@")[0] || "Anonym";

    const topicId = await ctx.db.insert("forumPosts", {
      userId,
      authorName,
      category: args.category,
      title: args.title,
      text: args.text,
      createdAt: now,
      updatedAt: now,
    });

    return topicId;
  },
});

// Create a reply
export const createReply = mutation({
  args: {
    topicId: v.id("forumPosts"),
    text: v.string(),
  },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Not authenticated");

    const user = await ctx.db.get(userId);
    if (!user) throw new Error("User not found");

    const topic = await ctx.db.get(args.topicId);
    if (!topic) throw new Error("Topic not found");

    const now = Date.now();
    const authorName = user.name || user.email?.split("@")[0] || "Anonym";

    // Create reply
    const replyId = await ctx.db.insert("forumPosts", {
      userId,
      authorName,
      category: topic.category,
      text: args.text,
      parentId: args.topicId,
      createdAt: now,
      updatedAt: now,
    });

    // Update topic's updatedAt
    await ctx.db.patch(args.topicId, { updatedAt: now });

    return replyId;
  },
});

// Helper to extract shortcodes and delete images from text
async function deleteImagesFromText(ctx: any, text: string) {
  // Find all image shortcodes in text [🖼️:xxxxx]
  const shortcodeRegex = /\[🖼️:([a-z0-9]{5})\]/g;
  const matches = Array.from(text.matchAll(shortcodeRegex));
  
  for (const match of matches) {
    const code = match[1];
    const shortcode = await ctx.db
      .query("imageShortcodes")
      .withIndex("by_code", (q: any) => q.eq("code", code))
      .first();
    
    if (shortcode) {
      // Delete the file from storage
      try {
        await ctx.storage.delete(shortcode.storageId);
        console.log(`Deleted image from storage: ${shortcode.storageId}`);
      } catch (e) {
        console.error(`Failed to delete image ${shortcode.storageId}:`, e);
      }
      // Delete the shortcode record
      await ctx.db.delete(shortcode._id);
    }
  }
}

// Delete a post (only own posts)
export const deletePost = mutation({
  args: { postId: v.id("forumPosts") },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Not authenticated");

    const post = await ctx.db.get(args.postId);
    if (!post) throw new Error("Post not found");

    // Check ownership or admin
    const user = await ctx.db.get(userId);
    const isAdmin = user?.role === "admin" || user?.role === "manager" || user?.role === "moderator";
    
    if (post.userId !== userId && !isAdmin) {
      throw new Error("Not authorized");
    }

    // If it's a topic, delete all replies first (including their images)
    if (!post.parentId) {
      const replies = await ctx.db
        .query("forumPosts")
        .withIndex("by_parent", (q) => q.eq("parentId", args.postId))
        .collect();
      
      for (const reply of replies) {
        // Delete images from reply
        if (reply.text) {
          await deleteImagesFromText(ctx, reply.text);
        }
        await ctx.db.delete(reply._id);
      }
    }

    // Delete images from the post itself
    if (post.text) {
      await deleteImagesFromText(ctx, post.text);
    }

    await ctx.db.delete(args.postId);
  },
});

// Toggle pin (all users can pin/unpin)
export const togglePin = mutation({
  args: { topicId: v.id("forumPosts") },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Not authenticated");

    const topic = await ctx.db.get(args.topicId);
    if (!topic || topic.parentId) throw new Error("Topic not found");

    await ctx.db.patch(args.topicId, { isPinned: !topic.isPinned });
  },
});

// Increment view count
export const incrementViews = mutation({
  args: { topicId: v.id("forumPosts") },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Not authenticated");

    const topic = await ctx.db.get(args.topicId);
    if (!topic || topic.parentId) throw new Error("Topic not found");

    await ctx.db.patch(args.topicId, { views: (topic.views ?? 0) + 1 });
  },
});

// Toggle like on a reply
export const toggleLike = mutation({
  args: { postId: v.id("forumPosts") },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Not authenticated");

    const post = await ctx.db.get(args.postId);
    if (!post) throw new Error("Post not found");

    const likedBy = post.likedBy ?? [];
    const isLiked = likedBy.includes(userId);

    if (isLiked) {
      // Remove like
      await ctx.db.patch(args.postId, { 
        likedBy: likedBy.filter(id => id !== userId) 
      });
    } else {
      // Add like
      await ctx.db.patch(args.postId, { 
        likedBy: [...likedBy, userId] 
      });
    }
  },
});
