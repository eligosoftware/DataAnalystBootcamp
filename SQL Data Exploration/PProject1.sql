select *
from covidDeaths
order by 3,4

--select *
--from covidVaccinations
--order by 3,4

-- select fields to query

Select location,date, total_cases,new_cases,total_deaths,new_deaths, population
from covidDeaths
order by 1,2

-- Looking for Total Cases vs Total Deaths
-- show the chance of dying from covid in country
Select location,date, total_cases,total_deaths, ROUND(total_deaths/total_cases*100,2) as DeathPercentage
from covidDeaths
where location like '%states%'
order by 1,2


-- Looking for Total Cases vs Population
-- show the part of population affected by covid in country
Select location,date, total_cases, population, ROUND(total_cases/population*100,2) as PopulationAffected
from covidDeaths
--where location like '%states%'
order by 1,2

-- look at countries with highest infection rate
Select location,population, max(total_cases) as HighestInfectionRate, max(ROUND(total_cases/population*100,2)) as PopulationAffected
from covidDeaths
--where location like '%states%'
group by location, population
order by PopulationAffected desc

-- show countries with the highest death count
Select location, max(total_deaths) as HighestDeathRate
from covidDeaths
where continent is not null
group by location
order by HighestDeathRate desc

-- show continents with the highest death count
Select continent, max(total_deaths) as HighestDeathRate
from covidDeaths
where continent is not null
group by continent
order by HighestDeathRate desc

-- show locations with the highest death count
Select location, max(total_deaths) as HighestDeathRate
from covidDeaths
where continent is null
group by location
order by HighestDeathRate desc

--GLOBAL NUMBERS
Select date, sum(new_cases), sum(new_deaths)--, sum(total_deaths), sum((total_deaths/total_cases) * 100) as DeathPercentage
from covidDeaths
where continent is not null
group by date
order by 1,2

-- looking at total population vs vaccinations
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION BY d.location order by d.location, d.date) as RollingPeopleVaccinated
from covidDeaths as d
join covidVaccinations as v
on d.location = v.location
and d.date = v.date
where d.continent is not null
order by 2,3

-- using CTE
with PopvsVac(Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION BY d.location order by d.location, d.date) as RollingPeopleVaccinated
from covidDeaths as d
join covidVaccinations as v
on d.location = v.location
and d.date = v.date
where d.continent is not null
and d.location like 'United States%'
--order by 2,3
) Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
from PopvsVac


--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION BY d.location order by d.location, d.date) as RollingPeopleVaccinated
from covidDeaths as d
join covidVaccinations as v
on d.location = v.location
and d.date = v.date
where d.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
from #PercentPopulationVaccinated

-- Creating view to store data for later visualisations
CREATE VIEW PercentPopulationVaccinated_View as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION BY d.location order by d.location, d.date) as RollingPeopleVaccinated
from covidDeaths as d
join covidVaccinations as v
on d.location = v.location
and d.date = v.date
where d.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
from PercentPopulationVaccinated_View