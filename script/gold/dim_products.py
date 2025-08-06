import pandas as pd
from collections import Counter

# Load and clean data
df = pd.read_csv("product_data.csv")
df = df[df['product_name'].notna()]
df = df[df['product_name'].str.lower() != 'n/a'].copy()

# Extract product_group_id
df['product_group_id'] = df['product_id'].astype(str).str[:5]
df['variant_id'] = df['product_id'].astype(str).str[5:]
# Step 1: Get common words per group
def get_common_words(names):
    all_words = [word for name in names for word in name.upper().split()]
    word_counts = Counter(all_words)
    # Keep words that appear in more than 1 name
    return [word for word, count in word_counts.items() if count > 1]

common_words_dict = (
    df.groupby('product_group_id')['product_name']
      .apply(get_common_words)
      .to_dict()
)

# Step 2: Extract base_name and variant using common words
def split_base_and_variant(row):
    name_words = str(row['product_name']).upper().split()
    common_words = common_words_dict.get(row['product_group_id'], [])

    # Case: No variant_id → treat full name as base
    if str(row['variant_id']).strip() == '':
        return pd.Series([
            ' '.join(name_words).title(),  # full product name as base
            'None'                         # no variant
        ])

    # Normal case: split by common words
    base_words = [w for w in name_words if w in common_words]
    variant_words = [w for w in name_words if w not in common_words]

    base = ' '.join(base_words).title() if base_words else 'None'
    variant = ' '.join(variant_words).title() if variant_words else 'None'

    return pd.Series([base, variant])

df[['product_base_name', 'variant_name']] = df.apply(split_base_and_variant, axis=1)

# Optional: Drop unused rows (no base name or no variant)
# df = df[df['product_base_name'].str.strip() != '']

# Show final result
df_final = df[[
    'product_key',
    'product_id',
    'product_group_id',
    'variant_id',
    'product_base_name',
    'variant_name',
]]
df_final.to_csv("dim_products.csv", index=False)
