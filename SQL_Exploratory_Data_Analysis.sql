/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views
*/

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM coviddth
where continent is not null
ORDER BY 1,2;


/* Looking at Total Cases & Total Deaths 
SO like for every total cases whats total death and its percentatge
It shows mortality rate effected due to covid in that country
*/

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Dth%'
FROM coviddth
where continent is not null
ORDER BY 1,2;



/* Looking at Total Cases & Population
Helps us identify what percentage of population has got it.
*/

SELECT Location, date, total_cases, total_deaths, population, (total_cases/population)*100  as 'Popul %'
FROM coviddth
where continent is not null
ORDER BY 1,2;



/* Looking at highest Countries iNfection rater v/s Population
*/


USE covd ;
SELECT Location, max(total_cases) as 'Max Total Cases',population, max((total_cases/population)*100)  as 'Popul %'
FROM coviddth
where continent is not null
GROUP BY location, population
ORDER BY 4 DESC;



/* Lookin at Total Population v/s Vaccinations*/

SELECT dt.date, dt.continent, dt.location, dt.population, vc.new_vaccinations,
SUM(vc.new_vaccinations) OVER 
(PARTITION BY dt.location ORDER BY dt.location,dt.date) as RollingPeopleCount
-- (RollingPeopleCount/dt.population)*100
FROM coviddth dt
JOIN covidvaccinationscsv vc
ON dt.location = vc.location 
	and dt.date = vc.date
where dt.continent is not null
ORDER BY 2,3;


/* -- Using CTE to perform Calculation on Partition By in previous query*/

WITH PoplVSVac (date, continent, location, population, NEw_Vacc,RollingPeopleCount )
as
(
SELECT dt.date, dt.continent, dt.location, dt.population, vc.new_vaccinations,
SUM(vc.new_vaccinations) OVER 
(PARTITION BY dt.location ORDER BY dt.location,dt.date) as RollingPeopleCount
-- (RollingPeopleCount/dt.population)*100
FROM coviddth dt
JOIN covidvaccinationscsv vc
ON dt.location = vc.location 
	and dt.date = vc.date
where dt.continent is not null
-- ORDER BY 2,3
)

SELECT *, (RollingPeopleCount/Population)*100 FROM PoplVSVac;


/* TEMP TABLE */
-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population int,
New_vaccinations int,
RollingPeopleVaccinated int
);

Insert into PercentPopulationVaccinated
SELECT dt.date, dt.continent, dt.location, dt.population, vc.new_vaccinations,
SUM(vc.new_vaccinations) OVER 
(PARTITION BY dt.location ORDER BY dt.location,dt.date) as RollingPeopleCount
-- (RollingPeopleCount/dt.population)*100
FROM coviddth dt
JOIN covidvaccinationscsv vc
ON dt.location = vc.location 
	and dt.date = vc.date
where dt.continent is not null;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dt.date, dt.continent, dt.location, dt.population, vc.new_vaccinations,
SUM(vc.new_vaccinations) OVER 
(PARTITION BY dt.location ORDER BY dt.location,dt.date) as RollingPeopleCount
-- (RollingPeopleCount/dt.population)*100
FROM coviddth dt
JOIN covidvaccinationscsv vc
ON dt.location = vc.location 
	and dt.date = vc.date
where dt.continent is not null;





















