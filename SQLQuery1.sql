select * 
from CovidDeaths
order by 3,4


--seeing the data
select Location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2


--loking at total cases vs total deaths
-- shows that 3.5% of affected were dieing
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like 'indi%'
order by 5 DESC


-- Looking at total case vs population
--shows the percentage of population got covid
--very intresting to note that only 1.388% of population of india got covid
select Location,date,total_cases,population,(total_cases/population)*100 as PopulationAffected
from CovidDeaths
where location like 'indi%'
order by 1,2

--Country with most infection rate of covid
select Location,population,MAX(total_cases),MAX((total_cases/population))*100 as PopulationAffected
from CovidDeaths
group by population,location
order by PopulationAffected DESC

--cheaking countries with highest death count per population
select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount DESC
--by continent
select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1,2

--seeing total population vs vaccinations
select dea.continent,dea.location,dea.date,population,vac.new_vaccinations
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--PopVsVac
select dea.continent,dea.location,dea.date,population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as PeopleVaccinated
,(PeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- we cant use the clm we just created in same query
--using CTE solving the above
with PopVsVac(Continent, Location, Date, Population,New_Vaccinations, PeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as PeopleVaccinated
--,(PeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(PeopleVaccinated/Population)*100
from PopVsVac

--using temp table
drop Table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Loaction nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
select dea.continent,dea.location,dea.date,population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as PeopleVaccinated
--,(PeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select * ,(PeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated



--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


select *
from PercentPopulationVaccinated