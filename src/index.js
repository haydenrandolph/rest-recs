const express = require('express');
const {Logging} = require('@google-cloud/logging');

const app = express();
const logging = new Logging();
const log = logging.log('restaurant-recommendation-logs');

// setting restaurants array
const restaurants = [
{
    name: 'Pizza Hut',
    style: 'Italian',
    address: 'Wherever Street 99, Somewhere',
    openHour: '09:00',
    closeHour: '23:00',
    vegetarian: 'yes',
    doesDeliveries: "yes"
},
{
    name: "Burgers & Fries",
    style: "American",
    address: "123 Pasta Lane, Rome City",
    openHour: "10:00",
    closeHour: "22:00",
    vegetarian: "yes",
    doesDeliveries: "yes"
},
{
    name: "Le Gourmet",
    style: "French",
    address: "456 Bistro Blvd, Paris Town",
    openHour: "11:00",
    closeHour: "23:00",
    vegetarian: "no",
    doesDeliveries: "no"
},
{
    name: "Seoul Food",
    style: "Korean",
    address: '789 Kimchi Street, Seoul City',
    openHour: '09:00',
    closeHour: '23:00',
    vegetarian: 'yes',
    doesDeliveries: "yes"
},
{
    name: "Pancake House",
    style: "Breakfast",
    address: "321 Road, North Pole",
    openHour: "05:00",
    closeHour: "12:00",
    vegetarian: "no",
    doesDeliveries: "no"
},
];

// check if restaurant is open
function isOpen(restaurant) {
  const currentTime = new Date();
  const openTime = new Date(currentTime.toDateString() + ' ' + restaurant.openHour);
  const closeTime = new Date(currentTime.toDateString() + ' ' + restaurant.closeHour);
  return currentTime >= openTime && currentTime <= closeTime;
}

// get restaurant rec - optional params. allows users to have optionality. 
app.get('/getRestaurant', async (req, res) => {
  const { style, vegetarian, doesDeliveries } = req.query;

  const requestEntry = log.entry({ httpRequest: req }, { 
    message: `Received request for style: ${style}, vegetarian: ${vegetarian}, doesDeliveries: ${doesDeliveries}` 
  });
  await log.write(requestEntry);
  const recommendation = restaurants.find(restaurant => 
    (style ? restaurant.style === style : true) &&
    (vegetarian ? restaurant.vegetarian === vegetarian : true) &&
    (doesDeliveries ? restaurant.doesDeliveries === doesDeliveries : true) &&
    isOpen(restaurant)
  );
  if (recommendation) {
    res.json({ restaurantRecommendation: recommendation });
    const responseEntry = log.entry({ httpRequest: req }, { 
      message: `Responded with restaurant: ${recommendation.name}` 
    });
    await log.write(responseEntry);
  } else {
    res.status(404).json({ error: 'No matching restaurant found or it is currently closed.' });
    const notFoundEntry = log.entry({ httpRequest: req }, { 
      message: 'No matching restaurant found or it is currently closed.' 
    });
    await log.write(notFoundEntry);
  }
});

// listening
const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`Restaurant recommendation service listening on port ${port}`);
});
