/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[HousingData]

---------------------------------------------------------------------------------------------
--Standardize Date Format
----------------------------------------------------------------------------------------------
 
--1. Convert sale date to date only format to see what it looks like.

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..HousingData

-- 2. Update the original sale date column with the new format

UPDATE HousingData
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE HousingData
ADD SaleDateConverted Date

UPDATE HousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject..HousingData

----------------------------------------------------------------------------------------------
-- Populate Property Address
------------------------------------------------------------------------------------------------

-- 1. Figure out where the property address is missing

SELECT PropertyAddress
FROM PortfolioProject..HousingData
--WHERE PropertyAddress is null
ORDER BY ParcelID

-- 2. Since ParcelID is the same with Property address, we populate using parcelID by using a self join

SELECT a.parcelID, a.PropertyAddress, b.parcelID, b.propertyaddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..HousingData a
JOIN PortfolioProject..HousingData b
	on a.parcelID = b.parcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..HousingData a
JOIN PortfolioProject..HousingData b
	on a.parcelID = b.parcelID
	AND a.[UniqueID] <> b.[UniqueID]

------------------------------------------------------------------------------------------------
-- Breaking out Address into individual Columns (Address, City, State) by using substring
------------------------------------------------------------------------------------------------

SELECT PropertyAddress
FROM PortfolioProject..HousingData

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM PortfolioProject..HousingData
 

ALTER TABLE HousingData
ADD PropertySplitAddress NVARCHAR(255)

UPDATE HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
  
ALTER TABLE HousingData
ADD PropertySplitCity NVARCHAR(255)

UPDATE HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--To see new changes made to the table
SELECT *
FROM PortfolioProject..HousingData

-- Splitting OwnerAddress

SELECT owneraddress
FROM PortfolioProject..HousingData

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject..HousingData

ALTER TABLE HousingData
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

  
ALTER TABLE HousingData
ADD OwnerSplitCity NVARCHAR(255)

UPDATE HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE HousingData
ADD OwnerSplitState NVARCHAR(255)

UPDATE HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM PortfolioProject..HousingData

--------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in Sold as Vacant field
--------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT(SoldasVacant), Count(SoldAsVacant)
FROM PortfolioProject..HousingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..HousingData

UPDATE HousingData
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..HousingData

------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates
-------------------------------------------------------------------------------------------------------------------------

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
FROM PortfolioProject..HousingData
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

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
FROM PortfolioProject..HousingData
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

------------------------------------------------------------------------------------------------------------------------
--Remove Unused Columns
-------------------------------------------------------------------------------------------------------------------------

SELECT * 
FROM PortfolioProject..HousingData

ALTER TABLE PortfolioProject..HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..HousingData
DROP COLUMN SaleDate