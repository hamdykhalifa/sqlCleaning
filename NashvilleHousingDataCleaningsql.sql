

Select * 
From PortfolioProjectAlexFreberg..Nashville

-------------------------------------------------------------
-- Change Sale Date

Alter Table Nashville
Add SaleDateConverted Date;

Update Nashville
SET SaleDateConverted = CONVERT(date, SaleDate)

Select SaleDateConverted, CONVERT(date, SaleDate)
From PortfolioProjectAlexFreberg..Nashville

-------------------------------------------------------------
-- Populate Property Address data 

Select PropertyAddress
From PortfolioProjectAlexFreberg..Nashville
Where PropertyAddress is null


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b. PropertyAddress, ISNULL(a. PropertyAddress, b.PropertyAddress)
From PortfolioProjectAlexFreberg..Nashville a
Join PortfolioProjectAlexFreberg..Nashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress =  ISNULL(a. PropertyAddress, b.PropertyAddress)
From PortfolioProjectAlexFreberg..Nashville a
Join PortfolioProjectAlexFreberg..Nashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-----------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Adress, City, State)

Select PropertyAddress
From PortfolioProjectAlexFreberg..Nashville

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(', ', PropertyAddress)- 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(', ', PropertyAddress) +1 , LEN(PropertyAddress)) as City

From PortfolioProjectAlexFreberg..Nashville


Alter Table PortfolioProjectAlexFreberg..Nashville
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProjectAlexFreberg..Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(', ', PropertyAddress)- 1)

Alter Table PortfolioProjectAlexFreberg..Nashville
Add PropertySplitCity Nvarchar(255);

Update PortfolioProjectAlexFreberg..Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(', ', PropertyAddress) +1 , LEN(PropertyAddress))

Select * 
From PortfolioProjectAlexFreberg..Nashville



-- Owner Adress split
Select OwnerAddress
From PortfolioProjectAlexFreberg..Nashville

Select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
, PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
, PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProjectAlexFreberg..Nashville


Alter Table PortfolioProjectAlexFreberg..Nashville
Add OwnerStreet Nvarchar(255);

Update PortfolioProjectAlexFreberg..Nashville
SET OwnerStreet = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table PortfolioProjectAlexFreberg..Nashville
Add OwnerCity Nvarchar(255);

Update PortfolioProjectAlexFreberg..Nashville
SET OwnerCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter Table PortfolioProjectAlexFreberg..Nashville
Add OwnerState Nvarchar(255);

Update PortfolioProjectAlexFreberg..Nashville
SET OwnerState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioProjectAlexFreberg..Nashville

------------------------------------------------------------------------

-- Change Y to Yes and N to No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjectAlexFreberg..Nashville
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProjectAlexFreberg..Nashville


Update PortfolioProjectAlexFreberg..Nashville
SET SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
						   When SoldAsVacant = 'N' Then 'No'
						   Else SoldAsVacant
						   End
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjectAlexFreberg..Nashville
Group by SoldAsVacant
order by 2

--------------------------------------------------------------------
-- Remove Duplicates

With RowNumCTE as(
Select *, 
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num

From PortfolioProjectAlexFreberg..Nashville
--order by ParcelID
)
Select * 
From RowNumCTE
Where row_num > 1
order by PropertyAddress

---------------------------------------------------
-- Delete unused columns

Select *
From PortfolioProjectAlexFreberg..Nashville

Alter Table  PortfolioProjectAlexFreberg..Nashville
Drop Column OwnerAddress, TaxDistrict, propertyAddress

Alter Table  PortfolioProjectAlexFreberg..Nashville
Drop Column SaleDate


