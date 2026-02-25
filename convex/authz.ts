import { query } from "./_generated/server";
import { getAuthUserId } from "@convex-dev/auth/server";

// Admin email - automatically has admin role
const ADMIN_EMAIL = "lukas.pozdisek@gmail.com";

// Role hierarchy (higher number = more permissions)
export const ROLES = {
  user: { level: 0, label: "Uživatel", color: "gray" },
  moderator: { level: 1, label: "Moderátor", color: "blue" },
  manager: { level: 2, label: "Správce", color: "purple" },
  admin: { level: 3, label: "Administrátor", color: "red" },
} as const;

export type UserRole = keyof typeof ROLES;

export const isAdmin = query({
  args: {},
  handler: async (ctx) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) return false;
    
    const user = await ctx.db.get(userId);
    if (!user) return false;
    
    // Check if user has admin role OR is the designated admin email
    return user.role === "admin" || user.email === ADMIN_EMAIL;
  },
});

// Check if user is at least a manager (manager or admin)
export const isManager = query({
  args: {},
  handler: async (ctx) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) return false;
    
    const user = await ctx.db.get(userId);
    if (!user) return false;
    
    return user.role === "admin" || user.role === "manager" || user.email === ADMIN_EMAIL;
  },
});

// Check if user is at least a moderator (moderator, manager, or admin)
export const isModerator = query({
  args: {},
  handler: async (ctx) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) return false;
    
    const user = await ctx.db.get(userId);
    if (!user) return false;
    
    return user.role === "admin" || user.role === "manager" || user.role === "moderator" || user.email === ADMIN_EMAIL;
  },
});

// Get current user's role
export const getCurrentUserRole = query({
  args: {},
  handler: async (ctx): Promise<UserRole | null> => {
    const userId = await getAuthUserId(ctx);
    if (!userId) return null;
    
    const user = await ctx.db.get(userId);
    if (!user) return null;
    
    // Admin email always gets admin role
    if (user.email === ADMIN_EMAIL) return "admin";
    
    return (user.role as UserRole) || "user";
  },
});

export const getCurrentUserId = query({
  args: {},
  handler: async (ctx) => {
    return await getAuthUserId(ctx);
  },
});
