/*
	Clearing Data
*/

Select *
from NashvilleH

-- Standardize Date Format

-- this example is for the case, SaleDate column has VARCHAR type
-- in my database the data was already converted during import and these steps are only written for learning purpose
select SaleDate, CONVERT(Date, SaleDate)
from NashvilleH

-- created new column
Alter table NashvilleH
Add SaleDateConverted Date

Update NashvilleH
set SaleDateConverted= CONVERT(Date, SaleDate)

select SaleDateConverted
from NashvilleH

-- Populate Property Address Data

select t1.ParcelID, t1.PropertyAddress, t2.ParcelID, t2.PropertyAddress, ISNULL(t1.PropertyAddress,t2.PropertyAddress)
from NashvilleH as t1
join NashvilleH as t2
	on t1.ParcelID = t2.ParcelID
	and t1.UniqueID <> t2.UniqueID
where t1.PropertyAddress is null

update t1
set PropertyAddress = ISNULL(t1.PropertyAddress,t2.PropertyAddress)
from NashvilleH as t1
join NashvilleH as t2
	on t1.ParcelID = t2.ParcelID
	and t1.UniqueID <> t2.UniqueID
where t1.PropertyAddress is null
--where PropertyAddress is null

-- Break Address into Individual Columns

Select PropertyAddress
from NashvilleH
-- delete rows without PropertyAddress
Delete from NashvilleH
where UniqueID in ('50922','50923', '29944')

Delete from NashvilleH
where UniqueID is null

-- Select Address and City from PropertyAddress
Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as City
from NashvilleH

-- Add 2 extra fields for Address and City to table
ALTER Table NashvilleH
Add PropertySplitAddress Nvarchar(255)

ALTER Table NashvilleH
Add PropertySplitCity Nvarchar(255)

--And set their values
Update NashvilleH
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Update NashvilleH
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))


select OwnerAddress
from NashvilleH

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleH


-- Add 3 extra fields for Address, City and State to table to store Owner Address
ALTER Table NashvilleH
Add OwnerSplitAddress Nvarchar(255)

ALTER Table NashvilleH
Add OwnerSplitCity Nvarchar(255)

ALTER Table NashvilleH
Add OwnerSplitState Nvarchar(255)


Update NashvilleH
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Update NashvilleH
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Update NashvilleH
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from NashvilleH

-- Change Y and N to Yes and No in "Sold as Vacant" field

select SoldAsVacant, COUNT(SoldAsVacant) as cnt
from NashvilleH
group by SoldAsVacant
order by cnt

select SoldAsVacant,
CASE
	WHEN SoldAsVacant = 1 THEN 'Yes'
	WHEN SoldAsVacant = 0 THEN 'No'
END
from NashvilleH

ALTER Table NashvilleH
Add SoldAsVacantString Nvarchar(255)

UPDATE NashvilleH
SET SoldAsVacantString = CASE
	WHEN SoldAsVacant = 1 THEN 'Yes'
	WHEN SoldAsVacant = 0 THEN 'No'
END

Select *
from NashvilleH

select SoldAsVacantString, COUNT(SoldAsVacantString) as cnt
from NashvilleH
group by SoldAsVacantString
order by cnt

-- Remove Dublicates
with RowNumCTE as(
Select *,
ROW_NUMBER() OVER (
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
				) row_num
from NashvilleH
)
select *--Delete
from RowNumCTE
where row_num > 1 

alter table NashvilleH
drop column OwnerAddress, TaxDistrict, PropertyAddress

Select *
from NashvilleH

alter table NashvilleH
drop column SaleDate