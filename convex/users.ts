import { query, mutation, internalMutation } from "./_generated/server";
import { Doc } from "./_generated/dataModel";
import { getAuthUserId } from "@convex-dev/auth/server";
import { v } from "convex/values";
import { alphabet, generateRandomString } from "oslo/crypto";

// Get current logged in user
export const currentLoggedInUser = query({
  args: {},
  handler: async (ctx) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) return null;
    const user = await ctx.db.get(userId);
    return user;
  },
});

// Update user profile
export const updateProfile = mutation({
  args: {
    name: v.optional(v.string()),
    surname: v.optional(v.string()),
    heightCm: v.optional(v.number()),
    targetWeightKg: v.optional(v.number()),
    birthDate: v.optional(v.number()),
    gender: v.optional(v.string()),
    goal: v.optional(v.string()),
    intensity: v.optional(v.string()),
    activityLevel: v.optional(v.string()),
    isUSMode: v.optional(v.boolean()),
    showPeptides: v.optional(v.boolean()),
    defaultSubstanceId: v.optional(v.string()),
    enabledSubstances: v.optional(v.array(v.string())),
    customIntervalEnabled: v.optional(v.boolean()),
    customIntervalAccepted: v.optional(v.boolean()),
    injectionIntervalDays: v.optional(v.number()),
    halfDayDosing: v.optional(v.boolean()),
    halfDayDosingAccepted: v.optional(v.boolean()),
    menstrualCycleStartDate: v.optional(v.number()),
    menstrualCycleLength: v.optional(v.number()),
    // Nutrition targets
    proteinGoalGrams: v.optional(v.number()),
    waterGoalMl: v.optional(v.number()),
    carbsPercent: v.optional(v.number()),
    fatsPercent: v.optional(v.number()),
    proteinPercent: v.optional(v.number()),
    manualCalorieTarget: v.optional(v.number()),
    // Treatment settings
    currentDoseMg: v.optional(v.number()),
    injectionDay: v.optional(v.string()),
    startWeightKg: v.optional(v.number()),
    weeklyWeightLossKg: v.optional(v.number()),
    // Theme and units
    themeMode: v.optional(v.string()),
    energyUnit: v.optional(v.string()),
    weightUnit: v.optional(v.string()),
    fluidUnit: v.optional(v.string()),
    heightUnit: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Not authenticated");

    await ctx.db.patch(userId, args);
    return { success: true };
  },
});

// Complete onboarding
export const completeOnboarding = mutation({
  args: {
    defaultSubstanceId: v.string(),
    name: v.string(),
    surname: v.string(),
    heightCm: v.optional(v.number()),
    targetWeightKg: v.optional(v.number()),
    birthDate: v.number(),
    gender: v.string(),
    goal: v.string(),
    intensity: v.string(),
    activityLevel: v.string(),
  },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Not authenticated");

    await ctx.db.patch(userId, {
      defaultSubstanceId: args.defaultSubstanceId,
      enabledSubstances: [args.defaultSubstanceId], // Enable the selected substance by default
      name: args.name,
      surname: args.surname,
      heightCm: args.heightCm,
      targetWeightKg: args.targetWeightKg,
      birthDate: args.birthDate,
      gender: args.gender,
      goal: args.goal,
      intensity: args.intensity,
      activityLevel: args.activityLevel,
      onboardingComplete: true,
    });
    return { success: true };
  },
});

// Check if user has active premium
export const checkPremiumStatus = query({
  args: {},
  handler: async (ctx) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) return { isPremium: false, reason: "not_authenticated" };
    
    const user = await ctx.db.get(userId);
    if (!user) return { isPremium: false, reason: "user_not_found" };
    
    // Permanent premium (set by admin)
    if (user.premiumPermanent) {
      return { isPremium: true, reason: "permanent", until: null };
    }
    
    // Time-limited premium (trial or promo code)
    if (user.premiumUntil) {
      const now = Date.now();
      if (user.premiumUntil > now) {
        return { isPremium: true, reason: "subscription", until: user.premiumUntil };
      }
    }
    
    // Legacy isPremium check (backward compatibility)
    if (user.isPremium) {
      return { isPremium: true, reason: "legacy", until: null };
    }
    
    return { 
      isPremium: false, 
      reason: "expired",
      trialActivated: user.trialActivated || false,
    };
  },
});

// Activate 60-day trial
export const activateTrial = mutation({
  args: {},
  handler: async (ctx) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Not authenticated");
    
    const user = await ctx.db.get(userId);
    if (!user) throw new Error("User not found");
    
    // Check if trial was already used
    if (user.trialActivated) {
      return { success: false, error: "Trial již byl využit" };
    }
    
    // 60 days from now
    const premiumUntil = Date.now() + (60 * 24 * 60 * 60 * 1000);
    
    await ctx.db.patch(userId, {
      trialActivated: true,
      premiumUntil,
      isPremium: true,
    });
    
    return { success: true, premiumUntil };
  },
});

// Redeem promo code
export const redeemPromoCode = mutation({
  args: { code: v.string() },
  handler: async (ctx, { code }) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Not authenticated");
    
    // Find the promo code
    const promoCode = await ctx.db
      .query("promoCodes")
      .withIndex("by_code", (q) => q.eq("code", code.toUpperCase()))
      .first();
    
    if (!promoCode) {
      return { success: false, error: "Neplatný promo kód" };
    }
    
    if (promoCode.usedBy) {
      return { success: false, error: "Tento kód již byl použit" };
    }
    
    // Calculate new premium end date
    const now = Date.now();
    const user = await ctx.db.get(userId);
    const currentEnd = user?.premiumUntil && user.premiumUntil > now ? user.premiumUntil : now;
    const durationMs = promoCode.durationMonths * 30 * 24 * 60 * 60 * 1000;
    const premiumUntil = currentEnd + durationMs;
    
    // Mark code as used
    await ctx.db.patch(promoCode._id, {
      usedBy: userId,
      usedAt: now,
    });
    
    // Update user premium
    await ctx.db.patch(userId, {
      premiumUntil,
      isPremium: true,
    });
    
    return { 
      success: true, 
      premiumUntil,
      productTitle: promoCode.productTitle,
      durationMonths: promoCode.durationMonths,
    };
  },
});

// Helper to send verification code via email
async function sendVerificationCode(email: string, code: string, action: "delete_account" | "change_password") {
  const actionText = action === "delete_account" ? "smazání účtu" : "změnu hesla";
  const response = await fetch(`${process.env.OTP_ENDPOINT}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      email,
      token: code,
      chatId: process.env.CHAT_ID,
      appName: `${process.env.APP_NAME} - Ověření pro ${actionText}` || "My App",
      secretKey: process.env.SECRET_KEY,
    }),
  });

  if (!response.ok) {
    throw new Error("Failed to send verification email");
  }
}

// Request account action verification (password change or delete)
export const requestAccountAction = mutation({
  args: { 
    action: v.union(v.literal("delete_account"), v.literal("change_password")),
  },
  handler: async (ctx, { action }) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Not authenticated");
    
    const user = await ctx.db.get(userId);
    if (!user || !user.email) throw new Error("User not found");
    
    // Generate 6-digit code
    const code = generateRandomString(6, alphabet("0-9"));
    const expires = Date.now() + 15 * 60 * 1000; // 15 minutes
    
    // Store pending action
    await ctx.db.patch(userId, {
      pendingAction: action,
      pendingActionCode: code,
      pendingActionExpires: expires,
    });
    
    // Send verification email
    await sendVerificationCode(user.email, code, action);
    
    return { success: true, email: user.email };
  },
});

// Verify code and change password
export const confirmPasswordChange = mutation({
  args: { 
    code: v.string(),
    newPassword: v.string(),
  },
  handler: async (ctx, { code, newPassword }) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Not authenticated");
    
    const user = await ctx.db.get(userId);
    if (!user) throw new Error("User not found");
    
    // Validate pending action
    if (user.pendingAction !== "change_password") {
      return { success: false, error: "Nebyla zahájena změna hesla" };
    }
    
    if (!user.pendingActionExpires || user.pendingActionExpires < Date.now()) {
      return { success: false, error: "Kód vypršel. Požádejte o nový." };
    }
    
    if (user.pendingActionCode !== code) {
      return { success: false, error: "Nesprávný kód" };
    }
    
    // Validate password
    if (newPassword.length < 8) {
      return { success: false, error: "Heslo musí mít alespoň 8 znaků" };
    }
    
    // Find the user's auth account with password provider
    const authAccounts = await ctx.db
      .query("authAccounts")
      .filter((q) => q.eq(q.field("userId"), userId))
      .collect();
    
    const passwordAccount = authAccounts.find(a => a.provider === "password");
    
    if (!passwordAccount) {
      return { success: false, error: "Účet nemá nastavené heslo" };
    }
    
    // Hash the new password using same method as @convex-dev/auth
    const encoder = new TextEncoder();
    const data = encoder.encode(newPassword);
    const hashBuffer = await crypto.subtle.digest("SHA-256", data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const hashedPassword = hashArray.map(b => b.toString(16).padStart(2, "0")).join("");
    
    // Update the password in authAccounts
    await ctx.db.patch(passwordAccount._id, {
      secret: hashedPassword,
    });
    
    // Clear pending action
    await ctx.db.patch(userId, {
      pendingAction: undefined,
      pendingActionCode: undefined,
      pendingActionExpires: undefined,
    });
    
    return { success: true };
  },
});

// Verify code and delete account
export const confirmAccountDeletion = mutation({
  args: { 
    code: v.string(),
  },
  handler: async (ctx, { code }) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Not authenticated");
    
    const user = await ctx.db.get(userId);
    if (!user) throw new Error("User not found");
    
    // Validate pending action
    if (user.pendingAction !== "delete_account") {
      return { success: false, error: "Nebylo zahájeno smazání účtu" };
    }
    
    if (!user.pendingActionExpires || user.pendingActionExpires < Date.now()) {
      return { success: false, error: "Kód vypršel. Požádejte o nový." };
    }
    
    if (user.pendingActionCode !== code) {
      return { success: false, error: "Nesprávný kód" };
    }
    
    // Delete all user data
    // Weight records
    const weightRecords = await ctx.db
      .query("weightRecords")
      .withIndex("by_user", (q) => q.eq("userId", userId))
      .collect();
    for (const record of weightRecords) {
      await ctx.db.delete(record._id);
    }
    
    // Injection records
    const injectionRecords = await ctx.db
      .query("injectionRecords")
      .withIndex("by_user", (q) => q.eq("userId", userId))
      .collect();
    for (const record of injectionRecords) {
      await ctx.db.delete(record._id);
    }
    
    // Measure records
    const measureRecords = await ctx.db
      .query("measureRecords")
      .withIndex("by_user", (q) => q.eq("userId", userId))
      .collect();
    for (const record of measureRecords) {
      await ctx.db.delete(record._id);
    }
    
    // Mood records
    const moodRecords = await ctx.db
      .query("moodRecords")
      .withIndex("by_user", (q) => q.eq("userId", userId))
      .collect();
    for (const record of moodRecords) {
      await ctx.db.delete(record._id);
    }
    
    // Water records
    const waterRecords = await ctx.db
      .query("waterRecords")
      .withIndex("by_user", (q) => q.eq("userId", userId))
      .collect();
    for (const record of waterRecords) {
      await ctx.db.delete(record._id);
    }
    
    // Protein records
    const proteinRecords = await ctx.db
      .query("proteinRecords")
      .withIndex("by_user", (q) => q.eq("userId", userId))
      .collect();
    for (const record of proteinRecords) {
      await ctx.db.delete(record._id);
    }
    
    // Stock items
    const stockItems = await ctx.db
      .query("stockItems")
      .withIndex("by_user", (q) => q.eq("userId", userId))
      .collect();
    for (const item of stockItems) {
      await ctx.db.delete(item._id);
    }
    
    // Auth accounts
    const authAccounts = await ctx.db
      .query("authAccounts")
      .filter((q) => q.eq(q.field("userId"), userId))
      .collect();
    for (const account of authAccounts) {
      await ctx.db.delete(account._id);
    }
    
    // Auth sessions
    const authSessions = await ctx.db
      .query("authSessions")
      .filter((q) => q.eq(q.field("userId"), userId))
      .collect();
    for (const session of authSessions) {
      await ctx.db.delete(session._id);
    }
    
    // Finally delete the user
    await ctx.db.delete(userId);
    
    return { success: true };
  },
});

// Get total member count for community
export const getMemberCount = query({
  args: {},
  handler: async (ctx) => {
    const users = await ctx.db.query("users").collect();
    return users.length;
  },
});

// Update user's last seen timestamp
export const updateLastSeen = mutation({
  args: {},
  handler: async (ctx) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) return;
    
    await ctx.db.patch(userId, {
      lastSeen: Date.now(),
    });
  },
});

// Get count of online users (active in last 5 minutes)
export const getOnlineCount = query({
  args: {},
  handler: async (ctx) => {
    const fiveMinutesAgo = Date.now() - 5 * 60 * 1000;
    const users = await ctx.db.query("users").collect();
    const onlineUsers = users.filter(u => u.lastSeen && u.lastSeen > fiveMinutesAgo);
    return onlineUsers.length;
  },
});
