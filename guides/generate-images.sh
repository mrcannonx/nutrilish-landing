#!/bin/bash
# Generate food images for PDF guides using Gemini 3.1 Flash Image Preview (Nano Banana 2)
# via the NutriLish generate-image edge function

set -euo pipefail

API_URL="https://uwypwjidnsuzquyjduag.supabase.co/functions/v1/generate-image"
ASSETS_DIR="$(dirname "$0")/assets"
mkdir -p "$ASSETS_DIR"

generate_image() {
  local filename="$1"
  local prompt="$2"
  local aspect="${3:-16:9}"
  local output="$ASSETS_DIR/$filename"

  if [ -f "$output" ]; then
    echo "  ⏭️  Skipping $filename (already exists)"
    return
  fi

  echo "  🎨 Generating: $filename"
  curl -s -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg p "$prompt" --arg a "$aspect" '{prompt: $p, aspect_ratio: $a, size: "1K"}')" \
    -o "$output" 2>/dev/null

  if file "$output" | grep -q "PNG image"; then
    local size=$(du -h "$output" | cut -f1)
    echo "    ✅ Done ($size)"
  else
    echo "    ❌ Failed — got $(file -b "$output" | cut -c1-40)"
    cat "$output" 2>/dev/null | head -1
    rm -f "$output"
  fi

  # Rate limit — be nice to the API
  sleep 2
}

echo "🍃 NutriLish Guide Image Generator"
echo "═══════════════════════════════════"
echo ""

# ─── Guide 1: 7-Day High Protein Meal Prep ───
echo "📄 Guide 1: High Protein Meal Prep"
generate_image "hero-meal-prep.png" \
  "Professional food photography: five dark meal prep containers arranged in a grid, each containing grilled chicken breast with brown rice and colorful vegetables, overhead flat lay shot on dark slate surface, warm studio lighting, food magazine editorial style, no text, no watermark" \
  "16:9"

generate_image "chicken-rice-bowl.png" \
  "Professional food photography: a single meal prep container with perfectly grilled chicken breast sliced, jasmine rice, steamed broccoli florets, overhead shot on dark wood surface, warm golden lighting, shallow depth of field, no text" \
  "16:9"

generate_image "salmon-sweet-potato.png" \
  "Professional food photography: baked salmon fillet with roasted sweet potato cubes and asparagus spears on a dark plate, dramatic side lighting, dark moody background, food magazine style, no text" \
  "16:9"

generate_image "prep-kitchen.png" \
  "Professional photography: organized meal prep kitchen scene with glass containers, cutting board with fresh vegetables, raw chicken breast, brown rice in a pot, overhead angle, warm lighting, dark countertop, no text" \
  "16:9"

# ─── Guide 2: Macro Cheat Sheet ───
echo ""
echo "📄 Guide 2: Macro Cheat Sheet"
generate_image "macro-foods-flat-lay.png" \
  "Professional food photography flat lay: variety of macro-balanced foods arranged neatly on dark surface — chicken breast, eggs, Greek yogurt, salmon, brown rice, sweet potato, broccoli, avocado, almonds, banana — minimalist spacing, top-down shot, studio lighting, no text" \
  "16:9"

# ─── Guide 3: 30-Minute Recipes ───
echo ""
echo "📄 Guide 3: 30-Minute Recipes"
generate_image "honey-garlic-chicken.png" \
  "Professional food photography: honey garlic glazed chicken pieces with sesame seeds over white jasmine rice in a dark bowl, chopsticks beside, dramatic moody lighting, dark background, no text" \
  "16:9"

generate_image "turkey-taco-bowl.png" \
  "Professional food photography: Mexican-style taco bowl with seasoned ground turkey, black beans, corn, sliced avocado, salsa, and brown rice in a dark bowl, overhead shot, vibrant colors, dark background, no text" \
  "16:9"

generate_image "shrimp-zoodles.png" \
  "Professional food photography: garlic butter shrimp over zucchini noodles with lemon wedge and parmesan, in a dark plate, warm lighting, dark slate background, food magazine style, no text" \
  "16:9"

generate_image "beef-stir-fry.png" \
  "Professional food photography: beef and broccoli stir-fry with glossy brown sauce over steamed white rice in a dark bowl, steam rising, moody lighting, dark background, no text" \
  "16:9"

# ─── Guide 4: Grocery List ───
echo ""
echo "📄 Guide 4: Smart Grocery List"
generate_image "grocery-produce.png" \
  "Professional photography: fresh groceries arranged beautifully on dark surface — colorful bell peppers, leafy greens, avocados, berries, sweet potatoes, lemons — organized by color, overhead shot, natural lighting, no text" \
  "16:9"

# ─── Guide 5: Cutting vs Bulking ───
echo ""
echo "📄 Guide 5: Cutting vs Bulking"
generate_image "cutting-meal.png" \
  "Professional food photography: clean eating plate with grilled chicken breast, large salad with mixed greens, cherry tomatoes, cucumber, light dressing on the side, portion-controlled, dark plate on dark surface, bright clean lighting, no text" \
  "16:9"

generate_image "bulking-meal.png" \
  "Professional food photography: large hearty meal — double portion steak with a mountain of white rice, roasted potatoes, mixed vegetables, generous portion sizes, dark plate on dark wood, warm rich lighting, no text" \
  "16:9"

# ─── Landing Page Thumbnails ───
echo ""
echo "📄 Landing Page Guide Thumbnails"
generate_image "thumb-meal-prep.png" \
  "Minimalist icon illustration: five meal prep containers arranged in a neat grid on dark background, clean modern graphic style, NutriLish green accent color #16A86E, no text" \
  "1:1"

generate_image "thumb-macros.png" \
  "Minimalist icon illustration: three colored circular charts representing protein (red), carbs (blue), and fat (purple) on dark background, clean modern graphic design, no text" \
  "1:1"

echo ""
echo "🎉 All images generated!"
echo "Assets in: $ASSETS_DIR"
ls -la "$ASSETS_DIR"/*.png 2>/dev/null | wc -l | xargs -I{} echo "Total: {} images"
