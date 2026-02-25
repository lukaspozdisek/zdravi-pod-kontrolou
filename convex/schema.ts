import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";
import { authTables } from "@convex-dev/auth/server";

const schema = defineSchema({
  ...authTables,
  users: defineTable({
    name: v.optional(v.string()),
    surname: v.optional(v.string()),
    image: v.optional(v.string()),
    email: v.optional(v.string()),
    emailVerificationTime: v.optional(v.number()),
    phone: v.optional(v.string()),
    phoneVerificationTime: v.optional(v.number()),
    isAnonymous: v.optional(v.boolean()),
    // Profile data
    heightCm: v.optional(v.number()),
    targetWeightKg: v.optional(v.number()),
    birthDate: v.optional(v.number()), // timestamp
    gender: v.optional(v.string()), // "male" | "female"
    goal: v.optional(v.string()), // "lose" | "maintain" | "gain"
    intensity: v.optional(v.string()), // "slow" | "normal" | "fast"
    activityLevel: v.optional(v.string()), // "none" | "light" | "medium" | "heavy"
    isUSMode: v.optional(v.boolean()),
    showPeptides: v.optional(v.boolean()),
    enabledSubstances: v.optional(v.array(v.string())), // ["tirz", "sema", "lira", "reta"]
    // Dosing schedule
    customIntervalEnabled: v.optional(v.boolean()), // user enabled custom interval (off-label)
    customIntervalAccepted: v.optional(v.boolean()), // user accepted off-label warning
    injectionIntervalDays: v.optional(v.number()), // 3-30 days between injections (only used if customIntervalEnabled)
    halfDayDosing: v.optional(v.boolean()), // half-day dosing mode
    halfDayDosingAccepted: v.optional(v.boolean()), // user accepted off-label warning
    // Onboarding
    defaultSubstanceId: v.optional(v.string()), // "tirz" | "sema" | "lira" | "reta"
    onboardingComplete: v.optional(v.boolean()),
    // Role
    role: v.optional(v.string()), // "admin" | "manager" | "moderator" | "user" (default)
    // Premium
    isPremium: v.optional(v.boolean()),
    premiumUntil: v.optional(v.number()), // timestamp until premium is active
    trialActivated: v.optional(v.boolean()), // has used 60-day trial?
    premiumPermanent: v.optional(v.boolean()), // permanently activated by admin
    // Admin per-user settings (overrides)
    adminAllowUSMode: v.optional(v.boolean()), // if false, disables US mode for this user
    adminAllowPeptides: v.optional(v.boolean()), // if false, disables peptides for this user
    adminAllowRetatrutide: v.optional(v.boolean()), // if false, disables Retatrutide for this user
    // Menstrual cycle (for women)
    menstrualCycleStartDate: v.optional(v.number()), // timestamp of last period start
    menstrualCycleLength: v.optional(v.number()), // cycle length in days (default 28)
    // Account management verification
    pendingAction: v.optional(v.string()), // "delete_account" | "change_password"
    pendingActionCode: v.optional(v.string()), // 6-digit verification code
    pendingActionExpires: v.optional(v.number()), // timestamp when code expires
    // Nutrition targets
    proteinGoalGrams: v.optional(v.number()), // daily protein goal in grams
    waterGoalMl: v.optional(v.number()), // daily water goal in ml
    carbsPercent: v.optional(v.number()), // carbs percentage (macros)
    fatsPercent: v.optional(v.number()), // fats percentage (macros)
    proteinPercent: v.optional(v.number()), // protein percentage (macros)
    manualCalorieTarget: v.optional(v.number()), // manual calorie override
    // Treatment settings
    currentDoseMg: v.optional(v.number()), // current dose in mg
    injectionDay: v.optional(v.string()), // preferred injection day of week
    startWeightKg: v.optional(v.number()), // starting weight for goals
    weeklyWeightLossKg: v.optional(v.number()), // target weekly weight loss
    // Theme and units
    themeMode: v.optional(v.string()), // "auto" | "dark" | "light"
    energyUnit: v.optional(v.string()), // "kcal" | "kj"
    weightUnit: v.optional(v.string()), // "kg" | "lbs"
    fluidUnit: v.optional(v.string()), // "ml" | "oz"
    heightUnit: v.optional(v.string()), // "cm" | "ft"
    // Online tracking
    lastSeen: v.optional(v.number()), // timestamp of last activity
  }).index("email", ["email"]),

  // Weight records
  weightRecords: defineTable({
    userId: v.id("users"),
    date: v.number(), // timestamp
    kg: v.number(),
  })
    .index("by_user", ["userId"])
    .index("by_user_date", ["userId", "date"]),

  // Injection records
  injectionRecords: defineTable({
    userId: v.id("users"),
    date: v.number(), // timestamp
    substanceId: v.string(), // "tirz" | "sema" | "lira" | "reta"
    mg: v.number(),
    site: v.optional(v.string()), // injection site
  })
    .index("by_user", ["userId"])
    .index("by_user_date", ["userId", "date"]),

  // Body measurement records
  measureRecords: defineTable({
    userId: v.id("users"),
    date: v.number(), // timestamp
    neck: v.optional(v.number()),
    chest: v.optional(v.number()),
    waist: v.optional(v.number()),
    hips: v.optional(v.number()),
    thigh: v.optional(v.number()),
    calf: v.optional(v.number()),
    arm: v.optional(v.number()),
  })
    .index("by_user", ["userId"])
    .index("by_user_date", ["userId", "date"]),

  // Mood/journal records
  moodRecords: defineTable({
    userId: v.id("users"),
    date: v.number(), // timestamp
    rating: v.number(), // 1-5 stars
    sideEffects: v.array(v.string()),
    note: v.optional(v.string()),
    levelAtTime: v.number(), // drug level at time of entry
  })
    .index("by_user", ["userId"])
    .index("by_user_date", ["userId", "date"]),

  // Water intake records (daily)
  waterRecords: defineTable({
    userId: v.id("users"),
    date: v.number(), // timestamp (start of day)
    glasses: v.number(), // number of glasses/activations
  })
    .index("by_user", ["userId"])
    .index("by_user_date", ["userId", "date"]),

  // Nutrition intake records (daily)
  proteinRecords: defineTable({
    userId: v.id("users"),
    date: v.number(), // timestamp (start of day)
    totalGrams: v.number(), // total protein in grams for the day
    totalKcal: v.optional(v.number()), // total kcal for the day
    totalCarbs: v.optional(v.number()), // total carbs in grams
    totalSugars: v.optional(v.number()), // total sugars in grams
    totalFiber: v.optional(v.number()), // total fiber in grams
    items: v.array(v.object({
      id: v.string(),
      name: v.string(),
      count: v.number(),
      proteinPerUnit: v.number(),
      kcalPerUnit: v.optional(v.number()),
      carbsPerUnit: v.optional(v.number()),
      sugarsPerUnit: v.optional(v.number()),
      fiberPerUnit: v.optional(v.number()),
    })), // list of food items added
  })
    .index("by_user", ["userId"])
    .index("by_user_date", ["userId", "date"]),

  // Promo codes for premium activation
  promoCodes: defineTable({
    code: v.string(), // unique promo code
    durationMonths: v.number(), // 1, 3, or 12
    productId: v.string(), // "monthly_sub", "quarterly_sub", "yearly_sub"
    productTitle: v.string(), // human readable name
    createdBy: v.id("users"), // admin who created
    createdAt: v.number(), // timestamp
    usedBy: v.optional(v.id("users")), // user who redeemed
    usedAt: v.optional(v.number()), // when redeemed
  })
    .index("by_code", ["code"])
    .index("by_creator", ["createdBy"]),

  // App settings (global, managed by admin)
  appSettings: defineTable({
    key: v.string(), // "global" - single settings document
    allowUSMode: v.boolean(), // Allow US mode in profile
    allowPeptides: v.boolean(), // Allow peptides mixing
    allowRetatrutide: v.boolean(), // Allow Retatrutide substance
  }).index("by_key", ["key"]),

  // Forum posts
  forumPosts: defineTable({
    userId: v.id("users"),
    authorName: v.string(),
    category: v.string(), // "chat", "glp1", "progress", etc.
    title: v.optional(v.string()), // only for topics, not replies
    text: v.string(),
    parentId: v.optional(v.id("forumPosts")), // null for topics, post id for replies
    isPinned: v.optional(v.boolean()),
    views: v.optional(v.number()), // view count for topics
    likedBy: v.optional(v.array(v.id("users"))), // users who liked this reply
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_user", ["userId"])
    .index("by_parent", ["parentId"])
    .index("by_category", ["category"])
    .index("by_created", ["createdAt"]),

  // Academy Categories
  academyCategories: defineTable({
    name: v.string(),
    description: v.optional(v.string()),
    icon: v.optional(v.string()), // lucide icon name
    color: v.optional(v.string()), // tailwind color class
    order: v.number(), // display order
    createdAt: v.number(),
    updatedAt: v.number(),
  }).index("by_order", ["order"]),

  // Academy Topics (within categories)
  academyTopics: defineTable({
    categoryId: v.id("academyCategories"),
    name: v.string(),
    description: v.optional(v.string()),
    order: v.number(),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_category", ["categoryId"])
    .index("by_category_order", ["categoryId", "order"]),

  // Academy Articles (within topics)
  academyArticles: defineTable({
    topicId: v.id("academyTopics"),
    title: v.string(),
    content: v.string(), // markdown content
    summary: v.optional(v.string()),
    order: v.number(),
    isPremium: v.optional(v.boolean()), // only for premium users
    images: v.optional(v.array(v.id("_storage"))), // uploaded images
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_topic", ["topicId"])
    .index("by_topic_order", ["topicId", "order"]),

  // Biohack Categories
  biohackCategories: defineTable({
    name: v.string(),
    description: v.optional(v.string()),
    icon: v.optional(v.string()), // lucide icon name
    color: v.optional(v.string()), // tailwind color class
    order: v.number(), // display order
    createdAt: v.number(),
    updatedAt: v.number(),
  }).index("by_order", ["order"]),

  // Biohack Topics (within categories)
  biohackTopics: defineTable({
    categoryId: v.id("biohackCategories"),
    name: v.string(),
    description: v.optional(v.string()),
    order: v.number(),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_category", ["categoryId"])
    .index("by_category_order", ["categoryId", "order"]),

  // Biohack Articles (within topics)
  biohackArticles: defineTable({
    topicId: v.id("biohackTopics"),
    title: v.string(),
    content: v.string(), // markdown content
    summary: v.optional(v.string()),
    order: v.number(),
    isPremium: v.optional(v.boolean()), // only for premium users
    images: v.optional(v.array(v.id("_storage"))), // uploaded images
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_topic", ["topicId"])
    .index("by_topic_order", ["topicId", "order"]),

  // Magazín Categories
  magazinCategories: defineTable({
    name: v.string(),
    description: v.optional(v.string()),
    icon: v.optional(v.string()),
    color: v.optional(v.string()),
    order: v.number(),
    createdAt: v.number(),
    updatedAt: v.number(),
  }).index("by_order", ["order"]),

  // Magazín Topics
  magazinTopics: defineTable({
    categoryId: v.id("magazinCategories"),
    name: v.string(),
    description: v.optional(v.string()),
    order: v.number(),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_category", ["categoryId"])
    .index("by_category_order", ["categoryId", "order"]),

  // Magazín Articles
  magazinArticles: defineTable({
    topicId: v.id("magazinTopics"),
    title: v.string(),
    content: v.string(),
    summary: v.optional(v.string()),
    order: v.number(),
    isPremium: v.optional(v.boolean()),
    images: v.optional(v.array(v.id("_storage"))),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_topic", ["topicId"])
    .index("by_topic_order", ["topicId", "order"]),

  // Stories (Příběhy proměny) Categories
  storiesCategories: defineTable({
    name: v.string(),
    description: v.optional(v.string()),
    icon: v.optional(v.string()),
    color: v.optional(v.string()),
    order: v.number(),
    createdAt: v.number(),
    updatedAt: v.number(),
  }).index("by_order", ["order"]),

  // Stories Topics
  storiesTopics: defineTable({
    categoryId: v.id("storiesCategories"),
    name: v.string(),
    description: v.optional(v.string()),
    order: v.number(),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_category", ["categoryId"])
    .index("by_category_order", ["categoryId", "order"]),

  // Stories Articles
  storiesArticles: defineTable({
    topicId: v.id("storiesTopics"),
    title: v.string(),
    content: v.string(),
    summary: v.optional(v.string()),
    order: v.number(),
    isPremium: v.optional(v.boolean()),
    images: v.optional(v.array(v.id("_storage"))),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_topic", ["topicId"])
    .index("by_topic_order", ["topicId", "order"]),

  // News articles (simple list without categories)
  newsArticles: defineTable({
    title: v.string(),
    content: v.string(),
    summary: v.optional(v.string()),
    isPinned: v.optional(v.boolean()), // pinned articles show first
    images: v.optional(v.array(v.id("_storage"))), // uploaded images
    createdAt: v.number(),
    updatedAt: v.number(),
  }).index("by_date", ["createdAt"]),

  // Stock/inventory items
  stockItems: defineTable({
    userId: v.id("users"),
    name: v.string(),
    substanceId: v.string(),
    isVial: v.boolean(),
    totalMg: v.number(),
    currentMg: v.number(),
    // Vial config
    vialMg: v.optional(v.number()),
    vialMl: v.optional(v.number()),
    // Pen config
    penType: v.optional(v.string()),
    penColor: v.optional(v.string()),
  }).index("by_user", ["userId"]),

  // Image shortcodes - maps short 5-char codes to storage IDs
  imageShortcodes: defineTable({
    code: v.string(), // 5-char unique code
    storageId: v.id("_storage"),
    createdAt: v.number(),
  }).index("by_code", ["code"]),

  // User custom foods - user's personal food items
  userCustomFoods: defineTable({
    userId: v.id("users"),
    name: v.string(),
    detail: v.string(), // e.g. "150g (porce)"
    protein: v.number(),
    carbs: v.number(),
    sugars: v.optional(v.number()),
    fiber: v.number(),
    kcal: v.number(),
    icon: v.optional(v.string()), // emoji (optional, fallback if no image)
    imageId: v.optional(v.id("_storage")), // uploaded photo
    createdAt: v.number(),
  }).index("by_user", ["userId"]),

  // Custom foods - admin-added food items
  customFoods: defineTable({
    name: v.string(),
    detail: v.string(), // e.g. "150g (porce)"
    protein: v.number(),
    carbs: v.number(),
    sugars: v.optional(v.number()), // sugar content in grams
    fiber: v.number(),
    kcal: v.number(),
    icon: v.string(), // emoji
    imageId: v.optional(v.id("_storage")), // uploaded photo
    tabId: v.string(), // "tab_protein" | "tab_energy" | "tab_fiber"
    categoryName: v.string(), // category within the tab
    order: v.number(),
    isActive: v.optional(v.boolean()), // soft delete
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_tab", ["tabId"])
    .index("by_tab_category", ["tabId", "categoryName"]),
});

export default schema;
