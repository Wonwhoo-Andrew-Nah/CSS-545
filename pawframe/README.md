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