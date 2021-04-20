pragma solidity ^0.5.17;

import './SafeMath.sol';

library Paging {
    struct Page {
        uint256 totalRecords;
        uint256 totalPages;
        uint256 pageRecords;
        uint256 pageSize;
        uint256 pageNumber;
    }

    using SafeMath for uint256;

    function getPage(
        uint256 totalRecords,
        uint256 pageSize,
        uint256 pageNumber
    ) internal pure returns (Page memory) {
        Page memory page = Page(totalRecords, 0, 0, 0, 1);
        if (totalRecords == 0 || pageSize == 0) return page;

        page.pageSize = (pageSize > 50) ? 50 : pageSize;
        page.pageRecords = page.pageSize;
        page.totalPages = totalRecords.div(page.pageSize);
        uint256 lastPageRecords = totalRecords.mod(page.pageSize);
        if (lastPageRecords > 0) page.totalPages = page.totalPages.add(1);

        if (pageNumber > 1) page.pageNumber = pageNumber;
        if (page.pageNumber > page.totalPages) page.pageNumber = page.totalPages;

        if (page.pageNumber == page.totalPages && lastPageRecords > 0) page.pageRecords = lastPageRecords;

        return page;
    }
}
