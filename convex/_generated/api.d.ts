/* eslint-disable */
/**
 * Generated `api` utility.
 *
 * THIS CODE IS AUTOMATICALLY GENERATED.
 *
 * To regenerate, run `npx convex dev`.
 * @module
 */

import type * as ResendOTP from "../ResendOTP.js";
import type * as academy from "../academy.js";
import type * as admin from "../admin.js";
import type * as auth from "../auth.js";
import type * as authz from "../authz.js";
import type * as biohack from "../biohack.js";
import type * as foods from "../foods.js";
import type * as forum from "../forum.js";
import type * as health from "../health.js";
import type * as http from "../http.js";
import type * as magazin from "../magazin.js";
import type * as media from "../media.js";
import type * as news from "../news.js";
import type * as opengraph from "../opengraph.js";
import type * as records from "../records.js";
import type * as stories from "../stories.js";
import type * as users from "../users.js";

import type {
  ApiFromModules,
  FilterApi,
  FunctionReference,
} from "convex/server";

declare const fullApi: ApiFromModules<{
  ResendOTP: typeof ResendOTP;
  academy: typeof academy;
  admin: typeof admin;
  auth: typeof auth;
  authz: typeof authz;
  biohack: typeof biohack;
  foods: typeof foods;
  forum: typeof forum;
  health: typeof health;
  http: typeof http;
  magazin: typeof magazin;
  media: typeof media;
  news: typeof news;
  opengraph: typeof opengraph;
  records: typeof records;
  stories: typeof stories;
  users: typeof users;
}>;

/**
 * A utility for referencing Convex functions in your app's public API.
 *
 * Usage:
 * ```js
 * const myFunctionReference = api.myModule.myFunction;
 * ```
 */
export declare const api: FilterApi<
  typeof fullApi,
  FunctionReference<any, "public">
>;

/**
 * A utility for referencing Convex functions in your app's internal API.
 *
 * Usage:
 * ```js
 * const myFunctionReference = internal.myModule.myFunction;
 * ```
 */
export declare const internal: FilterApi<
  typeof fullApi,
  FunctionReference<any, "internal">
>;

export declare const components: {};
