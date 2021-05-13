# 查询账户历史记录

```cgo
function getHistory(
        bytes32 topic,
        address account,
        uint256 pageSize,
        uint256 pageNumber
    ) public view returns (Action[] memory, Paging.Page memory)
```

## abi
```json
{
      "constant": true,
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "topic",
          "type": "bytes32"
        },
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "pageSize",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "pageNumber",
          "type": "uint256"
        }
      ],
      "name": "getHistory",
      "outputs": [
        {
          "components": [
            {
              "internalType": "bytes32",
              "name": "actionType",
              "type": "bytes32"
            },
            {
              "internalType": "bytes32",
              "name": "fromAsset",
              "type": "bytes32"
            },
            {
              "internalType": "uint256",
              "name": "fromAmount",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "fromPrice",
              "type": "uint256"
            },
            {
              "internalType": "bytes32",
              "name": "toAsset",
              "type": "bytes32"
            },
            {
              "internalType": "uint256",
              "name": "toAmount",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "toPrice",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "time",
              "type": "uint256"
            }
          ],
          "internalType": "struct IHistory.Action[]",
          "name": "",
          "type": "tuple[]"
        },
        {
          "components": [
            {
              "internalType": "uint256",
              "name": "totalRecords",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "totalPages",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "pageRecords",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "pageSize",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "pageNumber",
              "type": "uint256"
            }
          ],
          "internalType": "struct Paging.Page",
          "name": "",
          "type": "tuple"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    },
```

## Action定义
```cgo
    struct Action {
        bytes32 actionType;
        bytes32 fromAsset;
        uint256 fromAmount;
        uint256 fromPrice;
        bytes32 toAsset;
        uint256 toAmount;
        uint256 toPrice;
        uint256 time;
    }
```

## Paging.Page定义
```cgo
    struct Page {
        uint256 totalRecords;
        uint256 totalPages;
        uint256 pageRecords;
        uint256 pageSize;
        uint256 pageNumber;
    }
```

## 参数说明
- topic: 固定用'Stake'
- account: 要查询账号地址
- pageSize: 分页大小
- pageNumber: 分页编号，从1开始

## 返回值说明
- Action.actionType: ['Stake', 'Mint', 'Burn', 'Transfer']，分别表示
- Action.fromAsset: 
- Action.fromAmount: 
- Action.fromPrice: 
- Action.toAsset: 
- Action.toAmount: 
- Action.toPrice: 
- Action.time: 

- Page.totalRecords: 总记录数
- Page.totalPages: 总页面数
- Page.pageRecords: 当前页面记录数
- Page.pageSize: 每页记录数
- Page.pageNumber: 当前页数，下标从1开始

## eg


```json
{
  '0': [
    [
      '0x4d696e7400000000000000000000000000000000000000000000000000000000',
      '0x4554480000000000000000000000000000000000000000000000000000000000',
      '1000000000000000000',
      '0',
      '0x6455534400000000000000000000000000000000000000000000000000000000',
      '1289030043526666666666',
      '0',
      '1620914980',
      actionType: '0x4d696e7400000000000000000000000000000000000000000000000000000000',
      fromAsset: '0x4554480000000000000000000000000000000000000000000000000000000000',
      fromAmount: '1000000000000000000',
      fromPrice: '0',
      toAsset: '0x6455534400000000000000000000000000000000000000000000000000000000',
      toAmount: '1289030043526666666666',
      toPrice: '0',
      time: '1620914980'
    ],
    [
      '0x4d696e7400000000000000000000000000000000000000000000000000000000',
      '0x4554480000000000000000000000000000000000000000000000000000000000',
      '1000000000000000000',
      '0',
      '0x6455534400000000000000000000000000000000000000000000000000000000',
      '1260278864480000000000',
      '0',
      '1620914005',
      actionType: '0x4d696e7400000000000000000000000000000000000000000000000000000000',
      fromAsset: '0x4554480000000000000000000000000000000000000000000000000000000000',
      fromAmount: '1000000000000000000',
      fromPrice: '0',
      toAsset: '0x6455534400000000000000000000000000000000000000000000000000000000',
      toAmount: '1260278864480000000000',
      toPrice: '0',
      time: '1620914005'
    ],
    [
      '0x4d696e7400000000000000000000000000000000000000000000000000000000',
      '0x4554480000000000000000000000000000000000000000000000000000000000',
      '1000000000000000000',
      '0',
      '0x6455534400000000000000000000000000000000000000000000000000000000',
      '1260278864480000000000',
      '0',
      '1620913498',
      actionType: '0x4d696e7400000000000000000000000000000000000000000000000000000000',
      fromAsset: '0x4554480000000000000000000000000000000000000000000000000000000000',
      fromAmount: '1000000000000000000',
      fromPrice: '0',
      toAsset: '0x6455534400000000000000000000000000000000000000000000000000000000',
      toAmount: '1260278864480000000000',
      toPrice: '0',
      time: '1620913498'
    ]
  ],
  '1': [
    '3',
    '1',
    '3',
    '10',
    '1',
    totalRecords: '3',
    totalPages: '1',
    pageRecords: '3',
    pageSize: '10',
    pageNumber: '1'
  ]
}
```
