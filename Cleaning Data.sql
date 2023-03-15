/*
Cleaning Data in SQL Queries
*/


Select *
From CleaningData.dbo.HousingData

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDate, CONVERT(Date,SaleDate)
From CleaningData.dbo.HousingData


Update HousingData
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE HousingData
Add SaleDateConverted Date;

Update HousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From CleaningData.dbo.HousingData
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From CleaningData.dbo.HousingData a
JOIN CleaningData.dbo.HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From CleaningData.dbo.HousingData a
JOIN CleaningData.dbo.HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From CleaningData.dbo.HousingData


select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as City

From CleaningData.dbo.HousingData


alter table HousingData
add PropertySplitAddress nvarchar(255);

update HousingData
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table HousingData
add PropertySplitCity nvarchar(255);

update HousingData
set PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))



select OwnerAddress
From CleaningData.dbo.HousingData

Select
PARSENAME(replace(OwnerAddress,',','.'),3)
,PARSENAME(replace(OwnerAddress,',','.'),2)
,PARSENAME(replace(OwnerAddress,',','.'),1)
From CleaningData.dbo.HousingData



alter table HousingData
add OwnerSplitAddress nvarchar(255);

update HousingData
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table HousingData
add OwnerSplitCity nvarchar(255);

update HousingData
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)


alter table HousingData
add OwnerSplitState nvarchar(255);

update HousingData
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)


Select *
From CleaningData.dbo.HousingData



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from CleaningData.dbo.HousingData
group by SoldAsVacant




select SoldAsVacant,
 case when SoldAsVacant  = 1 then 'Yes' Else 'No'
    	 End 
from CleaningData.dbo.HousingData

alter table HousingData
add Vacant nvarchar(255);

update HousingData
set vacant = case when SoldAsVacant  = 1 then 'Yes' Else 'No'
    	 End 


select distinct(Vacant), count(Vacant)
from CleaningData.dbo.HousingData
group by Vacant




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with rownumcte as(
select *, 
ROW_NUMBER() over(
	partition by parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by
				 uniqueid
				 )row_num

from CleaningData.dbo.HousingData
)
select *
from rownumcte
where row_num > 1




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From CleaningData.dbo.HousingData

alter table CleaningData.dbo.HousingData
drop column owneraddress, Taxdistrict, propertyaddress






