/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM Project1.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Remove annoying H-M-S from SaleDate

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Project1.dbo.NashvilleHousing


SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM Project1.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


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
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- final udpates below
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Project1.dbo.NashvilleHousing AS a
JOIN Project1.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
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
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO


















