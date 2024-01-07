

## 題目

鏈上版的 whoscall 但標記的不是電話號碼 可以是一段網址或是信箱

## 角色
- 提供者
  - 標記者 RP
  - 投票者 VO
  - 提供者的收益來源
    - 沒收的資金池
    - 代幣買盤推漲的代幣單價
    - pool 的 reward

- 使用者 US

---
## 系統功能
- 儲值 - 成為對應角色以及執行功能需要支付token, 因此需要儲值功能
- 回報 - RP 可以對對應目標執行回報功能, 開啟後續投票功能
- 投票 - VO 可以對已經被回報的目標執行投票功能, 會影響目標的加權分數
- 獎勵 - 加權分數高的投票池內的使用者可以取回原本 token & 外還有 token 獎勵
- 讀取 - US 需要持有 `US_THRESHOLD` token 才能讀取資料

## Component
- Token - ERC20 token 用於獎勵 & 角色門檻
- Service
  - Mark - 實作標記功能
  - Vote - 實作投票功能
  - Read - 實作讀取功能
- RewardModal - 獎勵機制
- ProxyPattern for Service


## 變數
```javascript
RP_THRESHOLD // 成為回報者的門檻
VO_THRESHOLD // 成為投票者的門檻
US_THRESHOLD // 使用者要讀取資料的門檻
TAG_COST = 50 // 標記的費用
DEADLINE = 3 // 截止日期
QA_ALG() // 演算法
```

---
## 使用者故事
- 使用者成為 US
  - 使用者持有 `US_THRESHOLD` 數量的 token => 在每個 US 會呼叫的 function 加上 modifier
  - 
- 使用者成為 RP
  - 使用者持有 `RP_THRESHOLD` 數量的 token => 在每個 RP 會呼叫的 function 加上 modifier

- 使用者成為 VO
  - 使用者持有 `VO_THRESHOLD` 數量的 token => 在每個 VO 會呼叫的 function 加上 modifier
  
- RP 對 URL 標記 scam
  - RP 對 URL 標記 scam => protocol 轉移 RP `TAG_COST` token 到 pool
  
- VO 可以對被標記的 URL 投票, 假設 VO 投讚成票, URL 以特定演算法加權權重
  - VO 對 URL 投贊成票 => protocol 轉移 RP `QA_ALG(token amount)` token 到 贊成 pool
  
- VO 可以對被標記的 URL 投票, 假設 VO 投反對票, URL 以特定演算法減低權重
  - VO 對 URL 投贊成票 => protocol 轉移 RP `QA_ALG(token amount)` token 到 反對 pool
  - 
- VO 可以對 URL 進行檢索, 檢索是否有被投票以及加權紀錄, 藉此判定 URL 484 scam
  - VO 對 URL 呼叫鏈上 view 方法 進行查詢標記紀錄

---
## 漏洞
- Q. 如何預防亂投票的 RP ?
  - A. 持有一定數量 token 的門檻, e.g. 持有 `RP_THRESHOLD` token 才有投票權
  - A. 投票要質押一定數量 token, 當被認定是來亂的, 沒收 token e.g. 標記一個 URL 要先質押 50 token
- Q.如何預防假帳號 VO 灌票?
  - A. 持有一定數量 token 的門檻, e.g. 持有 `VO_THRESHOLD` token 才有投票權
  - A. 投票要質押一定數量 token, 當被認定是來亂的, 沒收 token e.g. 標記一個 URL 要先質押 50 token
- Q. 如何確保人多比錢多有更高權重?
  - A. Quadratic Funding 機制
- Q. 投票有沒有 deadline ?
  - A. 先假定 `DEADLINE` 天
- Q. 單一標記投入的 token 有沒有上限 ?
  - A. 好像沒必要 (?
- Q. 提供者角色如何取得對應報酬?
  - A. 參考最上方
- **Q. 使用者如何為資訊付費?**
  - A. 讀取時 reqiure `US_THRESHOLD` token 數量的門檻
- Q. 好像不能無限增發 token?
  - A. 學 BTC POS 機制, 發行上限


---
## token
- 當質押錯池子 沒收錯誤池子的資金 沒收一部分的資金用於獎勵正確的提供者 => 防止灌水, 假資訊
- 

## 一些很酷可能有幫助的 idea
- 