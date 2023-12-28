-- cleaning data in SQL queries

SELECT * FROM NashvilleHousingDataProject.dbo.NashvilleHousing


-- standardize date format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousingDataProject.dbo.NashvilleHousing

UPDATE NashvilleHousingDataProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, Saledate)

-- creating new column for converted sale date

ALTER TABLE NashvilleHousingDataProject.dbo.NashvilleHousing
ADD SaleDateConverted Date;

-- entry the data unto column of converted sale date

UPDATE NashvilleHousingDataProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, Saledate)

-- check the new converted saledate column

SELECT SaleDateConverted
FROM NashvilleHousingDataProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------

-- let's try to populate the property address data

-- check if there are rows that have incomplete information based on null value in property address column

SELECT *
FROM NashvilleHousingDataProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

-- there are quite a lot, let's try to sort it by the parcel id

SELECT *
FROM NashvilleHousingDataProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

-- let's populate the addresses rows with null value with the address that has the same parcel ID with the ones with the null value
-- try to join the parcel id and the property address

SELECT *
FROM NashvilleHousingDataProject.dbo.NashvilleHousing a
JOIN NashvilleHousingDataProject.dbo.NashvilleHousing b
-- we want to populate the null propertyaddress based off the same parcel ID but different unique ID
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

-- let's get the data we need like parcel ids, property addresses, and the property addresses that have null values

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleHousingDataProject.dbo.NashvilleHousing a
JOIN NashvilleHousingDataProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- now that we have the right query in mind, let's populate the null property address based off the same parcel ID
-- by using isnull, we can see the not null propertyaddress in b to the null propertyaddress in a

/*
redo this after updating data
*/

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingDataProject.dbo.NashvilleHousing a
JOIN NashvilleHousingDataProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- let's put the isnull query into the update to modify the null property address column in a

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingDataProject.dbo.NashvilleHousing a
JOIN NashvilleHousingDataProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- check the null data again
----------------------------------------------------------------------------------------------

-- breaking out Address into individual column (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousingDataProject.dbo.NashvilleHousing

-- METHOD 1 --
-- let's separate the value into three columns based on delimiter (,/comma) using substring and charindex
-- first let's create a select query to look at the data we're going to change so we are sure we're doing the right thing

--SELECT
--SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address
--FROM NashvilleHousingDataProject.dbo.NashvilleHousing

-- let's remove the comma behind the query to make the data more clean

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
FROM NashvilleHousingDataProject.dbo.NashvilleHousing 

-- now let's get the city too

--SELECT
--SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress), LEN(PropertyAddress)) AS City
--FROM NashvilleHousingDataProject.dbo.NashvilleHousing

-- uh oh, now let's erase the comma using +1 to make it more clean

SELECT
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM NashvilleHousingDataProject.dbo.NashvilleHousing

-- now that we have get the right data that we need, let's update the value
-- alter the table first using alter table then use update
-- for Address

ALTER TABLE NashvilleHousingDataProject.dbo.NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousingDataProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

-- for City

ALTER TABLE NashvilleHousingDataProject.dbo.NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousingDataProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- check the data again

SELECT * FROM NashvilleHousingDataProject.dbo.NashvilleHousing

-- METHOD 2
-- let's separate the value into three columns based on delimiter (,/comma) using PARSENAME that will convert the comma (,) into a period (.)
-- use the select to get the right query

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM NashvilleHousingDataProject.dbo.NashvilleHousing

-- you got the state data, PARSENAME is getting the data we want in reverse order
-- let's get the address, city and state data using parsename in descending order

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) AS State
FROM NashvilleHousingDataProject.dbo.NashvilleHousing

-- right query found, now let's alter the data in address, city, state order

-- for Address

ALTER TABLE NashvilleHousingDataProject.dbo.NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousingDataProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

-- for City

ALTER TABLE NashvilleHousingDataProject.dbo.NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousingDataProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

-- for State

ALTER TABLE NashvilleHousingDataProject.dbo.NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousingDataProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

-- check the result

SELECT * FROM NashvilleHousingDataProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- change Y and N to Yes and No in "SoldAsVacant" Column
/*
RUN THIS AGAIN AFTER UPDATE COMPLETE
*/

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)  AS CountSoldAsVacant
FROM NashvilleHousingDataProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- got the right data, now let's do the right thing
-- let's try to use the case function

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousingDataProject.dbo.NashvilleHousing

-- aight the function is correct, let's update SoldAsVacant

UPDATE NashvilleHousingDataProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-- run the select distinct query to make sure the task is complete successfully

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- remove duplicates
-- we're using row_number method and put it into a CTE
/*
RUN IT AGAIN AFTER DELETING TO CHECK THE DATA
*/
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
				) AS row_num
FROM NashvilleHousingDataProject.dbo.NashvilleHousing
)
SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY ParcelID

-- after checking the query, let's use DELETE to remove the duplicate datas

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
				) AS row_num
FROM NashvilleHousingDataProject.dbo.NashvilleHousing
)
DELETE FROM RowNumCTE
WHERE row_num > 1

-- check the data again
-- now check the overall data

SELECT *
FROM NashvilleHousingDataProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------
-- delete unused columns

SELECT *
FROM NashvilleHousingDataProject.dbo.NashvilleHousing

-- let's delete the unused column

ALTER TABLE NashvilleHousingDataProject.dbo.NashvilleHousing
DROP COLUMN TaxDistrict

-- also let's delete the original columns that we have separated and cleaned
ALTER TABLE NashvilleHousingDataProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate