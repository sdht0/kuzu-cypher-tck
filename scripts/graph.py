#!/usr/bin/env nix-shell
#!nix-shell --pure --keep NIX_PATH -i python3 -p "python3.withPackages (ps: with ps; [ matplotlib pandas ])"

# This file is part of the uutils coreutils package.
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.

# From https://github.com/uutils/coreutils-tracking

from datetime import datetime

import sys
import time

import matplotlib.pyplot as plt
import pandas as pd

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

ax = plt.gca()
df.plot(y="total", color="blue", ax=ax)
df.plot(y="pass", color="green", ax=ax, dashes=(4, 1))
df.plot(y="fail", color="gray", ax=ax, dashes=(2, 1))
df.plot(y="skip", color="violet", ax=ax, dashes=(8, 3))
plt.title("Kuzu TCK testsuite")
plt.xticks(rotation=45)
plt.ylim(ymin=0)
plt.savefig("results.png", dpi=199)
