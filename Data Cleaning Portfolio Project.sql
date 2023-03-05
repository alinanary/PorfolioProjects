/*

Cleaning Data in SQL Queries

*/


SELECT *
FROM Housing


-- Standardize Date Format

ALTER TABLE Housing
ADD SaleDateConverted Date

UPDATE Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-- Populate Property Address data

SELECT *
FROM Housing
WHERE PropertyAddress IS NULL



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b 
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b 
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL


-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Housing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM Housing


ALTER TABLE Housing
ADD PropertySplitAddress Nvarchar(255)

UPDATE Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE Housing
ADD PropertySplitCity Nvarchar(255)

UPDATE Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT * 
FROM Housing




SELECT OwnerAddress
FROM Housing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM Housing


ALTER TABLE Housing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


ALTER TABLE Housing
ADD OwnerSplitCity Nvarchar(255)

UPDATE Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)


ALTER TABLE Housing
ADD OwnerSplitState Nvarchar(255)

UPDATE Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


-- Change Y and N to Yes and No in "Sold as Vacant" filed

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Housing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END
FROM Housing

UPDATE Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END


-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
                            PropertyAddress,
                            SalePrice,
                            SaleDate,
                            LegalReference
                            ORDER BY
                                    UniqueID
                                    ) row_num
FROM Housing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Delete Unused Columns

SELECT *
FROM Housing


ALTER TABLE Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
