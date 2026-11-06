---
number: 5
title: "Add rate limiting to API endpoints"
labels: [SPEC]
---

## Problem

The API currently has no rate limiting, making it vulnerable to abuse. A single client can saturate all available resources, degrading service for other users.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Rate limiter middleware is applied to all `/api/` routes | `string` |
| SC-2 | Default limit is 100 requests per minute per IP | `string` |
| SC-3 | Rate limit headers (`X-RateLimit-Remaining`, `X-RateLimit-Reset`) are present in responses | `string` |
| SC-4 | Exceeded limit returns 429 status with `Retry-After` header | `string` |

## Implementation Plan

This section describes how to implement the feature:

1. Install `django-ratelimit` or equivalent middleware
2. Create a middleware class `RateLimitMiddleware` in `src/middleware.py`
3. Apply middleware to all `/api/` routes in `urls.py`
4. Add rate limit headers via response middleware
5. Write unit tests for each SC
6. Deploy to staging for validation

## Dependencies

None.
