--------------------------------------------------------------------------------------------------------------
-- Cleaning Data in SQL Queries
--------------------------------------------------------------------------------------------------------------
-- This is just to get a look at the data before we begin.
SELECT *
FROM [Portfolio Project 3]..NashvilleHousing;


--------------------------------------------------------------------------------------------------------------
-- Standardize sale date

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM [Portfolio Project 3]..NashvilleHousing;

-- This didnt seem to work for some reason
UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate);

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);


--------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

SELECT *
FROM [Portfolio Project 3]..NashvilleHousing
--WHERE PropertyAddress IS NULL;
ORDER BY ParcelID;

--ISNULL is useful for replacing values in a column.
SELECT 
	a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project 3]..NashvilleHousing a
JOIN [Portfolio Project 3]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project 3]..NashvilleHousing a
JOIN [Portfolio Project 3]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


--------------------------------------------------------------------------------------------------------------
-- Break out property address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM [Portfolio Project 3]..NashvilleHousing;

--SELECT LEFT(SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)), LEN(SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress))) - 1) AS Address
--FROM [Portfolio Project 3]..NashvilleHousing;

--Better way to do the above query
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
FROM [Portfolio Project 3]..NashvilleHousing;

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM [Portfolio Project 3]..NashvilleHousing;

Alter Table [Portfolio Project 3].dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE [Portfolio Project 3].dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

Alter Table [Portfolio Project 3].dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE [Portfolio Project 3].dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));


-- Owner Address clean up 

SELECT OwnerAddress
FROM [Portfolio Project 3].dbo.NashvilleHousing;

SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM [Portfolio Project 3].dbo.NashvilleHousing;

Alter Table [Portfolio Project 3].dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE [Portfolio Project 3].dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3);

Alter Table [Portfolio Project 3].dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE [Portfolio Project 3].dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2);

Alter Table [Portfolio Project 3].dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE [Portfolio Project 3].dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1);


--------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in SoldASVacant field

SELECT DISTINCT(SoldAsVacant)
FROM [Portfolio Project 3].dbo.NashvilleHousing;

SELECT
	DISTINCT(CASE
		WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
	END) AS SAV
FROM [Portfolio Project 3].dbo.NashvilleHousing;

UPDATE [Portfolio Project 3].dbo.NashvilleHousing
SET SoldAsVacant = CASE
					   WHEN SoldAsVacant = 'N' THEN 'No'
					   WHEN SoldAsVacant = 'Y' THEN 'Yes'
					   ELSE SoldAsVacant
				   END;


--------------------------------------------------------------------------------------------------------------
-- Remove duplicates (NOT BEST PRACTICE TO DELETE DATA FROM A DATABASE)

WITH RowNumCTE AS (
SELECT 
	*,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
						UniqueID
						) AS row_num
FROM [Portfolio Project 3].dbo.NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1;


------------------------------------------------------------------------------------------------------------
-- Delete unused columns (DONT DO THIS IN THE DATABASE USUALLY)

SELECT *
FROM [Portfolio Project 3].dbo.NashvilleHousing;

ALTER TABLE [Portfolio Project 3].dbo.NashvilleHousing
DROP COLUMN 
	OwnerAddress,
	TaxDistrict,
	PropertyAddress;

ALTER TABLE [Portfolio Project 3].dbo.NashvilleHousing
DROP COLUMN SaleDate;
