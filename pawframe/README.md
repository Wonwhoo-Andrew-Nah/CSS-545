# CSS-545

Checkout the [Proposal.pdf](./Proposal.pdf) document!

## Project Overview

Abandoned animals represent a significant social issue that requires careful attention. Unfortunately, public awareness of these animals is often limited unless individuals actively seek to adopt from shelters. In municipal or county shelters, animals are at risk of euthanasia when space is limited or when deemed "unadoptable". The length of time an animal remains available for adoption is largely dependent on the capacity and activity level of the shelter.

Given this circumstances, promoting the adoption of abandoned animals is critical to their survival.

The [King County pet adoption website](https://kingcounty.gov/en/dept/executive-services/animals-pets-pests/regional-animal-services/adopt-a-pet) offers a limited set of filters, including Animal Type, Age, Sex, and Location. Additionally, the UI features a scrollabe grid layout, which can make it challenging for users to efficiently navigate and explore available animals.

To address these limitations, this project aims to develop **a matching application for pet adoption**, inspired by platforms like Tinder, but focused on gelping users connect with aodpatable animals in King County. Leveraging [open data](https://data.kingcounty.gov/Pets/adoptable-pets/ytc8-tcih/about_data) provided by the [King County Open Data website](https://data.kingcounty.gov/), I will create a dataset to power the platform.

The application will be cross-platform, accessible on both mobile devices and PCs, and will be developed using `Flutter` with `Dart`.

## Initial mock up

### Target demographic

The app targets individuals interested in adopting pets, especially those looking for local animals at shelters. The design simplifies the adoption process, making it more accessible and engaging, particularly for younger users familiar with "matching" interfaces like dating apps.

### Happy Path

- Step 1: User is asked for their preferences (animal type, age, etc.) and location (zip code).
![Initial Mockup 1](./[UW]%20initial%20mockup.001.jpeg)
- Step 2: The app displays details and images of pets in their area, prioritizing those at risk of euthanasia.
![Initial Mockup 2](./[UW]%20initial%20mockup.002.jpeg)
- Step 3: Instructions are provided on how to adopt, including the difference between available and already-adopted pets.
- Step 4: The user submits an adoption request for their matched pet.
![Initial Mockup 3](./[UW]%20initial%20mockup.003.jpeg)

### Success Criteria

Success will be measured by the number of adoptions facilitated through the app, particularly of at-risk animals. User satisfaction, engagement (for example, social sharing can be a measure later on).

### Example

If the user enters their preferences and navigates away, they will return to the same screen with their previous input intact when they resume the app.

## Storage options

Our application stores data as follows.

- User's preferences
  - Animal Type (String)
  - Age (Boolean)
  - Zip Code (Int)
- Adoption data (JSON)
  - The animal's data user has decided to adopt.
  - This does not include all of the animal data.

### Possible options

|Options|Pros|Cons|
|---|---|---|
|Local Storage (shared_preferneces package) |Easy to implement for small data. Fast retrieval since data is stored on the device.Suitable for this app, where mainly stores primitive data types.|Limited to basic data types, Not idealistic for large datasets, like images or detailed animal profiles. while this application have to store image (animal image).|
|File Storage|Good for storing large data, including media files. Can handle data formats such as JSON for adoption data. File data is private to the app by default.|Requires management to ensure data is read and written correctly. Compared to databases, data may not be easily structured. Extra stops for secure data handling.|
|SQLite Database|Good for structured data, which applies to our options (preferences, and adoption data). can handle large datasets and complex queries. Data persistence across app sessions. So if user closes the app and reopen it, the preferences user has set before will be intact.|Storing image itself is not recommended, unless it is a path for the image. Complex to set up.|
|Cloud Storage: Firebase (firebase_core, cloud_firestore)|Daya can be synced across devices adn accessed from anywhere. Useful for large or shared data like user interactions. So it won't make any conflicts if any of the users try to adopt an animal. Backend support for user authentication and security.|Requires internet connectivity, but is mandatory for fetching animal data. Additional costs for data storage and transfer. Add complexity to app architecture with a need for proper API calls and handling.|

For this application, we will be using storage options as below.

- Local storage: basic user preferences
- Cloud Storage: saving animal data whether it is adopted (selected by any users) or not.

## Basic Functionality

- Saves user's preferences; Species, Age, ZIP for searching near shelters.
- Page view for searching abandoned animals.
- Filter option based on user's preference.
- Information retrieval from the county's animal shelter API.
  - More information when flipping the animal page.
- "Adopt" button on the back of the page.
- Gives user instruction after tapping "Adopt" button.
- After adoption, the page is colored as "Adopted".

## State management

The app implements tombstoning management (suspend/resume) using `shared_preferences` for local storage. 
This ensures that user preferences (animal type, age, ZIP code) and the app’s current state are preserved when the app is paused or closed, allowing users to resume from where they left off.


### Persisting UI State

`PawFrame` uses SharedPreferences to save data, such as the selected animal type, age, and ZIP code.  
This data will be restored when the app resumes or is relaunched, mimicking tombstoning.

### State Management with WidgetsBindingObserver

By implementing `WidgetsBindingObserver`, 
`PawFrame` can listen for changes to the app's lifecycle and handle suspend/resume actions.

### Restoring Page State on Resume

When the user comes back to the AnimalListScreen, 
we can ensure the "Adopted" message persists for adopted animals.

### Lifecycle Handling

Preferences are saved when the app is paused and reloads preferences when resumed.

### Adoption State

Animal adoption status persists with `shared_preferences` for quick restoration.

## Remaining Work (Beta Phase)

### To Be Completed

1. Data Integration
- Ensure data consistency between local and cloud storage. (aspirational)
- Complete the integration with King County Open Data API to fetch real-time animal data.

2. User Interface Enhancements

- Add animation transitions between screens for better user experience. (aspirational)
- Improve the user interface to provide clearer feedback when an animal is adopted.