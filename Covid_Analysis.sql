SELECT 
	Location, 
    date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    population
FROM newschema.DB_Covid_DEATHS
Order by location, date;

# looking at total cases vs total deaths
SELECT 
	Location, 
    date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    (total_deaths/total_cases)*100 AS DeathPercentage,      # Likelihood of dying by covid in Canada. 
    population
FROM newschema.DB_Covid_DEATHS
where location like '%canada%'
Order by location, date;


# Looking at totalcases vs population
# Shows what percentage of population got covid.
SELECT 
	Location, 
    date, 
    Population,
    total_cases, 
    (total_cases/population)*100 AS Percentinfected
FROM newschema.DB_Covid_DEATHS
where location like '%canada%'
Order by location, date; 

# Looking at countries with Highest infection rate compared to population.
SELECT 
	Location, 
    Population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM newschema.DB_Covid_DEATHS
# where location like '%canada%'
group by location, population
Order by PercentPopulationInfected desc;

#Showing countries with highest death count per population.
SELECT 
	Location, 
    MAX(total_deaths) AS TotalDeathCount
FROM newschema.DB_Covid_DEATHS
# where location like '%canada%'
group by location
Order by TotalDeathCount desc; # This query returns the group by, by the clusters. So, we get values like World, Upper middle income and high income with this query. 

#So we need this. 
SELECT 
	Location, 
    MAX(total_deaths) AS TotalDeathCount
FROM newschema.DB_Covid_DEATHS
# where location like '%canada%'
where continent is not null
group by location
Order by TotalDeathCount desc;

#Let's break things down by continent
SELECT 
	Location, 
    MAX(total_deaths) AS TotalDeathCount
FROM newschema.DB_Covid_DEATHS
# where location like '%canada%'
where continent is not null
group by location
Order by TotalDeathCount desc;

#Showing Continents with the highest death count per population.
SELECT 
	Continent, 
    MAX(total_deaths) AS TotalDeathCount
FROM newschema.DB_Covid_DEATHS
# where location like '%canada%'
where continent is not null
group by Continent
Order by TotalDeathCount desc;

#Global numbers
Select 
    sum(new_cases) AS Total_cases,
    sum(new_deaths) AS Total_deaths,
    sum(new_deaths)/sum(new_cases)*100 AS GlobalDeathPercentage
From newschema.DB_Covid_DEATHS
where continent is not null
order by date, location;

#Joining Deaths&Vacci
Select 
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations
From db_covid_deaths dea
Join DB_COVID_VACCINATIONS vac 
	ON dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
Order by 2,3;


#looking at total population vs vaccinations
Select
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    Sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From db_covid_deaths dea
Join DB_COVID_VACCINATIONS vac 
	ON dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
Order by 2,3;

#Use CTE's
With PopvsVAC (Continent,Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    Sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From db_covid_deaths dea
Join DB_COVID_VACCINATIONS vac 
	ON dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
#Order by 2,3
)
Select *,
(RollingPeopleVaccinated/Population)*100
From Popvsvac;

#Temp Table
Drop table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeoplevaccinated numeric
);

Insert Into PercentPopulationVaccinated
Select
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    Sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From db_covid_deaths dea
Join DB_COVID_VACCINATIONS vac 
	ON dea.location = vac.location
    and dea.date = vac.date
#where dea.continent is not null
#Order by 2,3;

Select
(RollingPeopleVaccinated/Population)*100
From percentpopulationVaccinated;

#------------------Creating Views to Store data for later Visualizatoins.----------------------------------------------
Create View VPercentPopulationVaccinated AS 
Select
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    Sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From db_covid_deaths dea
Join DB_COVID_VACCINATIONS vac 
	ON dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null;
#Order by 2,3

Create View TotalCases_VS_TotalDeaths AS 
SELECT 
	Location, 
    date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    (total_deaths/total_cases)*100 AS DeathPercentage,      # Likelihood of dying by covid in Canada. 
    population
FROM newschema.DB_Covid_DEATHS
where location like '%canada%'
Order by location, date;

Create View TotalCases_VS_Population AS 
SELECT 
	Location, 
    date, 
    Population,
    total_cases, 
    (total_cases/population)*100 AS Percentinfected
FROM newschema.DB_Covid_DEATHS
where location like '%canada%'
Order by location, date; 

Create View Countries_Highest_InfectionRate AS 
SELECT 
	Location, 
    Population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM newschema.DB_Covid_DEATHS
# where location like '%canada%'
group by location, population
Order by PercentPopulationInfected desc;

Create View Countries_Highest_Death_Count AS 
SELECT 
	Location, 
    MAX(total_deaths) AS TotalDeathCount
FROM newschema.DB_Covid_DEATHS
# where location like '%canada%'
group by location
Order by TotalDeathCount desc;

Create View GlobalDeaths AS 
Select 
    sum(new_cases) AS Total_cases,
    sum(new_deaths) AS Total_deaths,
    sum(new_deaths)/sum(new_cases)*100 AS GlobalDeathPercentage
From newschema.DB_Covid_DEATHS
where continent is not null
order by date, location;

Create View TotalPopulation_Vs_Vaccination AS 
Select
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    Sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From db_covid_deaths dea
Join DB_COVID_VACCINATIONS vac 
	ON dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
Order by 2,3;



















