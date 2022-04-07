

SELECT *
FROM PortfolioProject..['Covid deaths Spreadsheet$']
WHERE continent is not null
Order by 3, 4


--Select the Data that Im going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..['Covid deaths Spreadsheet$']
Order by 1, 2

-- Looking at Total Cases vs Total Deaths 
--Shows the liklyhood of death if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..['Covid deaths Spreadsheet$']
WHERE Location like '%states%'
Order by 1, 2

--on my birthday (5/31/2020) ~6.02% of covid patients died 

--Looking at the Total cases vs Population
--Shows what % got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
FROM PortfolioProject..['Covid deaths Spreadsheet$']
WHERE Location like '%states%'
Order by 1, 2

-- Looking at countries with highest infection rate compared to Population 
SELECT Location, Population, MAX(total_cases) as HighestinfectionCount, MAX((total_cases/population))*100 as PopulationPercentage
FROM PortfolioProject..['Covid deaths Spreadsheet$']
--WHERE Location like '%states%'
Group by Location, Population
Order by PopulationPercentage desc


-- Showing Countries with Highest Mortality rate per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..['Covid deaths Spreadsheet$']
--WHERE Location like '%states%'
WHERE continent is not null
Group by Location
Order by TotalDeathCount desc


--Breaking things down by Continent 


--Showing continents by highest death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..['Covid deaths Spreadsheet$']
--WHERE Location like '%states%'
WHERE continent is not null
Group by continent
Order by TotalDeathCount desc



-- Global numbers 

SELECT date,  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
From PortfolioProject..['Covid deaths Spreadsheet$']
--WERE location like '%states%' 
WHERE continent is not null 
GROUP BY date
order by 1, 2
--Total cases and deaths as a percentage
SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
From PortfolioProject..['Covid deaths Spreadsheet$']
--WERE location like '%states%' 
WHERE continent is not null 
--GROUP BY date
order by 1, 2

--Joining some tables

--Looking at total pop vs Vaccinations 

--
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject.. ['Covid Vaccinations$'] dea
Join PortfolioProject..['Covid deaths Spreadsheet$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
-- I made an error in my code, the vaccination and deaths tables were flipped, fixed

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated,
FROM PortfolioProject.. ['Covid deaths Spreadsheet$'] dea
Join PortfolioProject..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
order by 2,3


--Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)
--as (RollingPeopleVaccinated),
FROM PortfolioProject.. ['Covid deaths Spreadsheet$'] dea
Join PortfolioProject..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Locatoin nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)
--as (RollingPeopleVaccinated),
FROM PortfolioProject.. ['Covid deaths Spreadsheet$'] dea
Join PortfolioProject..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later 

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject.. ['Covid deaths Spreadsheet$'] dea
Join PortfolioProject..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated