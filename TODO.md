1. design record struct
2. design creditservice interface


## P1
1. marker 投票需要消耗 credit, if credit > 500 => revert; to avoid spam vote
2. marker's vote will push to scoreboard


## P2
1. mark 可以被 claim 的日期根據vote活躍度計算
2. Permission 各個角色的 limit 可以透過合約升級


## P3
1. 確認有哪些 variables 或是 model 可以被升級的