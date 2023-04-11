--Basic Data exploring of CovidDeaths and CovidVaccinations

Select * from  CovidDeaths
where continent is null
order by 3,4

Select * from  CovidVaccinations
order by 3,4

--Select Data that we will want to use
Select Location, date, total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Ratio_of_death_cases
from CovidDeaths
where total_deaths IS NOT NULL
order by 1,2,3,4

-- Looking at Total Cases vs Total Deaths for  Location For Singapore
--Likelihood of death if u contracted Covid
Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Percentage_of_death_cases
from CovidDeaths
where location like '%singapore%'
order by 1,2,3,4

-- Looking at Total Cases vs Population
--The percent of people who contracted Covid for each Location's Population

Select Location, date, total_cases,total_deaths,population,(total_cases/population)*100 as Percentage_of_cases
from CovidDeaths
order by 1,2,3,4

--Countries with highest infection rate compared to population

Select Location ,MAX(total_cases) as Highest_Infection_Rate,population, MAX(total_cases/population)*100 as Percentage_of_infected
from CovidDeaths
group by Location,population
order by Percentage_of_infected desc

--Showing COuntries with highest death count( total)

Select Location ,MAX(cast(total_deaths as int)) as Highest_Death_Rate  --cast to convert nvarchar to int so we can order
from CovidDeaths
where continent is not null--we dont want the continents to be inside.--
group by Location
order by Highest_Death_Rate desc

--By continent for death rates

Select continent ,MAX(cast(total_deaths as int)) as Highest_Death_Rate  --cast to convert nvarchar to int so we can order
from CovidDeaths
where continent is not null--we dont want the continents to be inside.--
group by continent
order by Highest_Death_Rate desc

-- Global Numbers
Select date , sum(new_cases) as Total_new_cases, sum(cast(new_deaths as int)) as Total_new_death_cases ,(sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_Percentage
from CovidDeaths
where continent is not null--we dont want the continents to be inside.--
group by date
order by Total_new_cases desc

--looking at total population vs Vaccinations
--joining two tables together: covid deaths and covid vaccination


Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) 
OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3

--CTE
With PopvsVac( Continent, Location, Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as (
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) 
OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100 
from PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) 
OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
--where dea.continent is not null
--order by 2,3
Select *,(RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated

-- Creating View to store data for later visualisations

Create View PercentPopulationVaccinated as 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) 
OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3








