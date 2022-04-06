require 'rails_helper'

RSpec.describe 'the application show page' do
  it 'shows the application attributes' do
    furry_friends = Shelter.create!(name: "Furry Friends", foster_program: true, city: "Denver", rank: "2")

    olive = furry_friends.pets.create!(name: "Olive", age: 2, breed: "dog", adoptable: true)

    application_4 = Application.create!(name: "Marky Mark", street_address: "678 I Way", city: "Richmond", zip_code: 23229, state: "VA", description: "Awaiting Information", status: "In progress")

    pet_application_5 = PetApplication.create!(pet_id: olive.id, application_id: application_4.id)

    visit "/applications/#{application_4.id}"

    # within "#application-#{application_4.id}" do

    expect(page).to have_content(application_4.name)
    expect(page).to have_content(application_4.street_address)
    expect(page).to have_content(application_4.city)
    expect(page).to have_content(application_4.zip_code)
    expect(page).to have_content(application_4.state)
    # expect(page).to have_content(application_4.status)
    # end
  end


  it 'links to the pets show page' do
    furry_friends = Shelter.create!(name: "Furry Friends", foster_program: true, city: "Denver", rank: "2")

    olive = furry_friends.pets.create!(name: "Olive", age: 2, breed: "dog", adoptable: true)

    application_4 = Application.create!(name: "Marky Mark", street_address: "678 I Way", city: "Richmond", zip_code: 23229, state: "VA", description: "Awaiting Information", status: "In progress")

    pet_application_5 = PetApplication.create!(pet_id: olive.id, application_id: application_4.id)

    visit "/applications/#{application_4.id}"

    click_link("#{olive.name}")
    expect(current_path).to eq("/pets/#{olive.id}")
  end

  it 'has a section to add pet to application' do
    furry_friends = Shelter.create!(name: "Furry Friends", foster_program: true, city: "Denver", rank: "2")

    olive = furry_friends.pets.create!(name: "Olive", age: 2, breed: "dog", adoptable: true)

    ozzy = furry_friends.pets.create!(name: "Ozzy", age: 1, breed: "dog", adoptable: true)

    application_4 = Application.create!(name: "Marky Mark", street_address: "678 I Way", city: "Richmond", zip_code: 23229, state: "VA", description: "", status: "In progress")

    pet_application_5 = PetApplication.create!(pet_id: olive.id, application_id: application_4.id)

    visit "/applications/#{application_4.id}"

    expect(page).to have_content("Add a Pet to this Application")
    expect(page).to have_button("Search")
    fill_in('Pet name', with: "#{ozzy.name}")
    click_button "Search"

    expect(current_path).to eq("/applications/#{application_4.id}")
    expect(page).to have_content("#{ozzy.name}")
  end

  it 'does not render the search bar if application is not in progress' do
    application_3 = Application.create!(name: "Steve Jobs", street_address: "456 I Way", city: "Richmond", zip_code: 23229, state: "VA", description: "Awaiting information", status: "Rejected")
    furry_friends = Shelter.create!(name: "Furry Friends", foster_program: true, city: "Denver", rank: "2")

    olive = furry_friends.pets.create!(name: "Olive", age: 2, breed: "dog", adoptable: true)
    pet_application_6 = PetApplication.create!(pet_id: olive.id, application_id: application_3.id, pet_app_status: false )


    visit "/applications/#{application_3.id}"

    expect(page).to_not have_content("Add a Pet to this Application")
  end

  it 'adds pet after clicking adopt this pet' do
    furry_friends = Shelter.create!(name: "Furry Friends", foster_program: true, city: "Denver", rank: "2")

    olive = furry_friends.pets.create!(name: "Olive", age: 2, breed: "dog", adoptable: true)

    ozzy = furry_friends.pets.create!(name: "Ozzy", age: 1, breed: "dog", adoptable: true)

    application_4 = Application.create!(name: "Marky Mark", street_address: "678 I Way", city: "Richmond", zip_code: 23229, state: "VA", description: "Awaiting Information", status: "In progress")

    pet_application_5 = PetApplication.create!(pet_id: olive.id, application_id: application_4.id)

    visit "/applications/#{application_4.id}"
    fill_in('Pet name', with: "#{ozzy.name}")
    click_button "Search"

    click_button "Adopt this Pet"
    expect(current_path).to eq("/applications/#{application_4.id}")
    expect(page).to have_content("Pets: | #{olive.name} | #{ozzy.name} |")
  end

  it 'After user adds pet(s) user sees a section to submit application' do
    furry_friends = Shelter.create!(name: "Furry Friends", foster_program: true, city: "Denver", rank: "2")

    olive = furry_friends.pets.create!(name: "Olive", age: 2, breed: "dog", adoptable: true)

    ozzy = furry_friends.pets.create!(name: "Ozzy", age: 1, breed: "dog", adoptable: true)

    application_4 = Application.create!(name: "Marky Mark", street_address: "678 I Way", city: "Richmond", zip_code: 23229, state: "VA", description: "Awaiting information", status: "In progress")

    # pet_application_5 = PetApplication.create!(pet_id: olive.id, application_id: application_4.id)

    visit "/applications/#{application_4.id}"
    expect(page).to_not have_content("Why I would be a good pet owner")
    fill_in('Pet name', with: "#{ozzy.name}")
    click_button "Search"

    click_button "Adopt this Pet"
    expect(page).to have_content("Why I would be a good pet owner")
    expect(page).to have_button("Submit my application")
    fill_in('description', with: 'I just love petting dogs, fam')

    click_button "Submit my application"
    expect(page).to have_content("Status : Pending")
    expect(page).to_not have_content("Status : In progress")
    expect(page).to_not have_button("Search")
    expect(page).to_not have_button("Submit my application")
  end

  it 'Before user adds pet(s), user cannot submit application' do
    furry_friends = Shelter.create!(name: "Furry Friends", foster_program: true, city: "Denver", rank: "2")

    ozzy = furry_friends.pets.create!(name: "Ozzy", age: 1, breed: "dog", adoptable: true)

    application_4 = Application.create!(name: "Marky Mark", street_address: "678 I Way", city: "Richmond", zip_code: 23229, state: "VA", description: "Awaiting information", status: "In progress")

    visit "/applications/#{application_4.id}"

    fill_in('Pet name', with: "#{ozzy.name}")
    click_button "Search"
    click_button "Adopt this Pet"

    click_button "Submit my application"
    expect(page).to_not have_content("Status : Pending")
    expect(page).to have_content("Status : In progress")
  end
end
