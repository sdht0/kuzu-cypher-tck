#!/usr/bin/env nix-shell
#!nix-shell --pure --keep NIX_PATH -i python3 -p "python3.withPackages (ps: with ps; [ seaborn pandas matplotlib ])"

import sys

import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

# Set seaborn style
sns.set_style("whitegrid")

if len(sys.argv) <= 1:
   print('graph.py: <json file>')
   sys.exit()

d = pd.read_json(sys.argv[1], orient="index")
df = pd.DataFrame(d)

df.columns.names = ["date"]

as_list = df.index.tolist()
for i in as_list:
    idx = as_list.index(i)
    as_list[idx] = i

df.index = as_list

print(df)

# Reset index to make it a column for seaborn
df_plot = df.reset_index()
df_plot.columns = ['date'] + list(df_plot.columns[1:])

# Create the stacked bar plot using matplotlib
plt.figure(figsize=(12, 8))

# Calculate remaining tests (total - pass - fail - skip)
df_plot['remaining'] = df_plot['total'] - df_plot['pass'] - df_plot['fail'] - df_plot['skip']

# Create stacked bar chart
bottom = None
colors = ['green', 'orange', 'yellow', 'lightblue']  # pass, fail, skip, remaining
labels = ['pass', 'fail', 'skip', 'remaining']

for i, (col, color, label) in enumerate(zip(['pass', 'fail', 'skip', 'remaining'], colors, labels)):
    if bottom is None:
        plt.bar(df_plot['date'], df_plot[col], color=color, label=label, alpha=0.8, width=3)
        bottom = df_plot[col]
    else:
        plt.bar(df_plot['date'], df_plot[col], bottom=bottom, color=color, label=label, alpha=0.8, width=3)
        bottom += df_plot[col]

plt.title("Kuzu TCK testsuite", fontsize=16, fontweight='bold')
plt.xlabel("Date", fontsize=12)
plt.ylabel("Number of Tests", fontsize=12)
plt.xticks(rotation=45, ha='right')
plt.ylim(ymin=0)
plt.legend(loc='upper left')
plt.grid(axis='y', alpha=0.3)
plt.tight_layout()
plt.savefig("results.png", dpi=199, bbox_inches='tight')

print("Done")
