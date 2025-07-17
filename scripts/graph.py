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

# Create the plot using seaborn
plt.figure(figsize=(10, 6))
sns.lineplot(data=df_plot, x="date", y="total", color="blue", linewidth=2, marker='o', markersize=6, label="total")
sns.lineplot(data=df_plot, x="date", y="pass", color="green", linewidth=2, linestyle="--", marker='o', markersize=6, label="pass")
sns.lineplot(data=df_plot, x="date", y="fail", color="gray", linewidth=2, linestyle=":", marker='o', markersize=6, label="fail")
sns.lineplot(data=df_plot, x="date", y="skip", color="violet", linewidth=2, linestyle="-.", marker='o', markersize=6, label="skip")

plt.title("Kuzu TCK testsuite")
plt.xticks(rotation=45)
plt.ylim(ymin=0)
plt.legend()
plt.tight_layout()
plt.savefig("results.png", dpi=199, bbox_inches='tight')

print("Done")
