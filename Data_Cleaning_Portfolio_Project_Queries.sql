/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM Project1.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Remove annoying H-M-S from SaleDate and add a year column

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Project1.dbo.NashvilleHousing

-- testing if the funcitons give what info we want
SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM Project1.dbo.NashvilleHousing

SELECT 
SUBSTRING(CAST(SaleDateConverted AS varchar), 1, CHARINDEX('-', CAST(SaleDateConverted AS varchar))-1) AS Year
FROM Project1.dbo.NashvilleHousing


--adding new columns for data
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

ALTER TABLE NashvilleHousing
ADD SaleYear int;


--update table
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

UPDATE NashvilleHousing
SET SaleYear = SUBSTRING(CAST(SaleDateConverted AS varchar), 1, CHARINDEX('-', CAST(SaleDateConverted AS varchar))-1)

--remove where year is 2019 since this is 2013-2016


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

-- found that when two rows have the same ParcelID, then they have the same PropertyAddress. So we can populate rows where PropertyAddress is null with correct data using ParcelID
SELECT *
FROM Project1.dbo.NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Project1.dbo.NashvilleHousing AS a
JOIN Project1.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

-- final udpates below
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Project1.dbo.NashvilleHousing AS a
JOIN Project1.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- check data
SELECT PropertyAddress
FROM Project1.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,	-- get stuff in PropertyAddress before comma
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address2   -- get stuff in PropertyAddress after comma
FROM Project1.dbo.NashvilleHousing


-- add the two columns from previous section to table using formulas from before
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NvarChar(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NvarChar(255);


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))




--checking what is in OwnerAddress column
SELECT OwnerAddress
FROM Project1.dbo.NashvilleHousing

--using PARSENAME and REPLACE to separate the OwnerAddress column
SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Project1.dbo.NashvilleHousing



-- add separated data to new columns
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NvarChar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NvarChar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NvarChar(255);

--update table with new columns for separated addresses
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



--------------------------------------------------------------------------------------------------------------------------





--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Project1.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


-- we can see that "Y" and "N" values are not as common, but mean the same thing as "Yes" and "No", so change "Y" and "N".
SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM Project1.dbo.NashvilleHousing


-- update the table
UPDATE NashvilleHousing
	SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
							WHEN SoldAsVacant = 'N' THEN 'No'
							ELSE SoldAsVacant
							END

-- went back to top statement to test if this ^ worked, and it did!


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


--create common table expression
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num


FROM Project1.dbo.NashvilleHousing
)

--Delete all rows from cte where there are duplicates
DELETE
FROM RowNumCTE
WHERE row_num > 1



---------------------------------------------------------------------------------------------------------

-- Delete columns that we don't need for analysis or were made irrelevant from previous alterations


SELECT *
FROM Project1.dbo.NashvilleHousing


ALTER TABLE Project1.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate, OwnerName;







-----------------------------------------------------------------------------------------------












