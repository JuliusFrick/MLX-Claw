# TikTok Slideshow Promotion Skill

## Purpose
Create viral TikTok slideshows automatically for app promotion or affiliate content.

## Core Workflow

### 1. Hook Research (Before Creating)
Always ask:
- "Who's the other person?"
- "What's the conflict?"
- "What's the transformation moment?"

**Viral Formula:**
> [Another person] + [conflict/doubt] → showed them AI → they changed their mind

**Working Hooks Examples:**
- "My landlord wouldn't let me decorate until I showed her these"
- "My mum wouldn't believe our kitchen could look like this"
- "I showed my boyfriend what AI thinks our bedroom could be"
- "My roommate said our place was fine. I showed her."

### 2. Image Generation Specs

**Always:**
- Format: 1024x1536 (portrait, 4:5 ratio)
- Model: gpt-image-1.5 with "iPhone photo" and "realistic lighting"
- Slides: exactly 6 per post
- Text overlay: hook on slide 1 only

**Room/Object Descriptions (LOCKED across all 6 slides):**
- Room dimensions
- Window count and position
- Door location
- Camera angle
- Furniture size and placement
- Ceiling height
- Floor type
- Lighting fixtures

**What CHANGES per slide (Style only):**
- Wall color
- Bedding/decor
- Furniture style
- Lighting fixtures
- Ambient mood

### 3. Caption Formula

**Structure:**
1. Hook (relates to image, mentions the app naturally)
2. Story (2-3 sentences, human moment)
3. CTA (implied - let them discover the app)
4. Max 5 hashtags

**Example:**
"My landlord wouldn't let me change anything in our rental. I showed her this. She literally said 'okay fine.' 😂 The app lets you redesign any room with AI before you commit."

### 4. Hashtags
Max 5, mix of broad and niche:
- #roommakeover #aiapp #designtok #homerenovation #aidedesign

## Image Generation Prompts

### Template (Room Transformation)
```
iPhone photo of a small [ROOM TYPE]. [DETAILED ARCHITECTURE - COPY ACROSS ALL 6 SLIDES]. [STYLE SPECIFIC TO THIS SLIDE]. Natural phone camera quality, realistic lighting, indoor daylight. Portrait orientation, 1024x1536.
```

### Real Example (Kitchen)
```
iPhone photo of a small UK rental kitchen. Narrow galley style kitchen, roughly 2.5m x 4m. Shot from the doorway at the near end, looking straight down the length. Countertops along the right wall with base cabinets and wall cabinets above. Small window on the far wall, centered, single pane, white UPVC frame, about 80cm wide. Left wall bare except for a small fridge freezer near the far end. Vinyl flooring. White ceiling, fluorescent strip light. Natural phone camera quality, realistic lighting. Portrait orientation.

Style for this slide: Modern Scandinavian, light oak cabinets, white countertops, hanging plants, warm pendant lights.
```

## Text Overlay Rules

- Font size: 6.5% of image height
- Position: Centered, below TikTok UI area
- Color: White with subtle shadow for readability
- Font: Clean sans-serif (Inter or SF Pro)

## Posting Workflow

1. Generate 6 images with locked architecture, changing only style
2. Add text overlay to slide 1 with hook
3. Write caption following formula
4. Upload to Postiz as draft (privacy: SELF_ONLY)
5. Notify human to add trending sound and publish

## Common Failures (Avoid These)

- [ ] Wrong aspect ratio (must be 1024x1536 portrait)
- [ ] Vague room descriptions (rooms look different on each slide)
- [ ] Text too small or hidden behind UI
- [ ] Self-focused hooks (talk about viewer, not yourself)
- [ ] Too many hashtags (>5)
- [ ] Adding people to room transformations (looks fake)

## Performance Tracking

Log every post:
- Hook used
- Views
- Likes
- Comments
- Follows

Update best-performing hooks in this file.

## Tools Available

- OpenAI API for image generation
- Postiz API for TikTok posting
- Claude for copywriting
