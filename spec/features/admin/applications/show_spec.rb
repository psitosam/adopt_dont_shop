require 'rails_helper'

describe 'Admin Appliction Show Page' do
  before do
    @shelter_1 = Shelter.create!(name: 'Aurora shelter', city: 'Aurora, CO', foster_program: false, rank: 9)
    @shelter_2 = Shelter.create!(name: 'RGV animal shelter', city: 'Harlingen, TX', foster_program: false, rank: 5)
    @shelter_3 = Shelter.create!(name: 'Fancy pets of Colorado', city: 'Denver, CO', foster_program: true, rank: 10)
    @shelter_4 = Shelter.create!(name: 'AAA Shelter', city: 'Denver, CO', foster_program: true, rank: 10)

    @moody = @shelter_2.pets.create!(name: 'Moody', breed: 'unidentified', age: 3, adoptable: true)
    @dilly = @shelter_4.pets.create!(name: 'Dilly', breed: 'unidentified', age: 3, adoptable: true)
    @pirate = @shelter_1.pets.create!(name: 'Mr. Pirate', breed: 'tuxedo shorthair', age: 5, adoptable: true)
    @clawdia = @shelter_1.pets.create!(name: 'Clawdia', breed: 'shorthair', age: 3, adoptable: true)
    @lucille = @shelter_3.pets.create!(name: 'Lucille Bald', breed: 'sphynx', age: 8, adoptable: true)

    @appl_1 = Application.create!(
      name: 'Johnny',
      street_address: '123 nowhere',
      city: 'HereTown',
      state: 'TH',
      zip_code: 99999,
      description: 'Awaiting Information...',
      status: 'Pending'
    )
    @appl_2 = Application.create!(
      name: 'Braunny',
      street_address: '654 Heretherehere',
      city: 'HereTown',
      state: 'TH',
      zip_code: 99999,
      description: 'Awaiting Information...',
      status: 'Pending'
    )
    @appl_3 = Application.create!(
      name: 'Doomy',
      street_address: '123 everywhere',
      city: 'NotHereTown',
      state: 'TH',
      zip_code: 12345,
      description: 'Awaiting Information...',
      status: 'Pending'
    )
    @appl_4 = Application.create!(
      name: 'Liddy',
      street_address: '1456 everywhere',
      city: 'HereHereTown',
      state: 'TH',
      zip_code: 12345,
      description: 'Awaiting Information...',
      status: 'Pending'
    )

    PetApplication.create!(pet_id: @pirate.id, application_id: @appl_1.id)
    PetApplication.create!(pet_id: @clawdia.id, application_id: @appl_1.id)
    PetApplication.create!(pet_id: @lucille.id, application_id: @appl_2.id)
    PetApplication.create!(pet_id: @moody.id, application_id: @appl_2.id)
    PetApplication.create!(pet_id: @moody.id, application_id: @appl_3.id)
    PetApplication.create!(pet_id: @dilly.id, application_id: @appl_3.id)
    PetApplication.create!(pet_id: @dilly.id, application_id: @appl_4.id)
  end

  it 'displays application information' do
    visit "/admin/applications/#{@appl_2.id}"

    expect(page).to have_content(@appl_2.name)
    expect(page).to have_content(@appl_2.street_address)
    expect(page).to have_content(@appl_2.city)
    expect(page).to have_content(@appl_2.state)
    expect(page).to have_content(@appl_2.zip_code)
    expect(page).to have_content(@appl_2.description)
    expect(page).to have_content(@appl_2.status)

    expect(page).not_to have_content(@appl_1.name)
    expect(page).not_to have_content(@appl_1.street_address)
  end

  it 'displays a list of pets being applied for' do
    visit "/admin/applications/#{@appl_2.id}"

    within("#pet-#{@moody.id}") do
      expect(page).to have_content(@moody.name)
      expect(page).to have_content(@moody.breed)
      expect(page).to have_content(@moody.age)
    end

    within("#pet-#{@lucille.id}") do
      expect(page).to have_content(@lucille.name)
      expect(page).to have_content(@lucille.breed)
      expect(page).to have_content(@lucille.age)
    end

    expect(page).not_to have_content(@pirate.name)
  end

  it 'has buttons to reject or approve pets' do
    visit "/admin/applications/#{@appl_2.id}"
    within("#pet-#{@moody.id}") do
      expect(page).to have_button("Approve")
      expect(page).to have_button("Reject")
    end
  end

  it 'will show approval message if approved, rejection if rejected' do
    visit "/admin/applications/#{@appl_2.id}"

    within("#pet-#{@moody.id}") do
      expect(page).to have_button("Approve")
      expect(page).to have_button("Reject")
      click_button "Approve"
      expect(page).to have_content("Pet has been approved!")
      expect(page).not_to have_button("Reject")
      expect(page).not_to have_button("Approve")
    end

    within("#pet-#{@lucille.id}") do
      expect(page).to have_button("Approve")
      expect(page).to have_button("Reject")
      click_button "Reject"
      expect(page).to have_content("Pet has been denied :(")
      expect(page).not_to have_button("Reject")
      expect(page).not_to have_button("Approve")
    end
  end

  it 'will not effect other pets on other applications' do
    visit "/admin/applications/#{@appl_2.id}"

    within("#pet-#{@moody.id}") do
      expect(page).to have_button("Approve")
      expect(page).to have_button("Reject")

      click_button "Approve"

      expect(page).to have_content("Pet has been approved!")
      expect(page).not_to have_button("Reject")
      expect(page).not_to have_button("Approve")
    end

    visit "/admin/applications/#{@appl_3.id}"

    within("#pet-#{@moody.id}") do
      expect(page).to have_button("Approve")
      expect(page).to have_button("Reject")
    end
  end

  it 'will mark the application as approved if all pets are approved' do
    visit "/admin/applications/#{@appl_2.id}"

    expect(page).to have_content("Appliction status:Pending")

    within("#pet-#{@moody.id}") do
      click_button "Approve"

      expect(page).to have_content("Pet has been approved!")
    end

    expect(page).to have_content("Appliction status:Pending")

    within("#pet-#{@lucille.id}") do
      click_button "Approve"

      expect(page).to have_content("Pet has been approved!")
    end

    expect(page).to have_content("Appliction status:Approved")
    # expect(@appl_2.status).to eq("Pending")
    # expect(@appl_2.status).to eq("Approved")
  end

  it 'will mark the application as rejected if any pets are rejected' do
    visit "/admin/applications/#{@appl_2.id}"

    expect(page).to have_content("Appliction status:Pending")

    within("#pet-#{@moody.id}") do
      click_button "Approve"

      expect(page).to have_content("Pet has been approved!")
    end

    expect(page).to have_content("Appliction status:Pending")

    within("#pet-#{@lucille.id}") do
      click_button "Reject"

      expect(page).to have_content("Pet has been denied :(")
    end

    expect(page).to have_content("Appliction status:Rejected")
    # expect(@appl_2.status).to eq("Pending")
    # expect(@appl_2.status).to eq("Rejected")
  end

  it 'makes pet unadoptable if they are included in any approved applications' do
    visit "/pets/#{@moody.id}"
    expect(page).to have_content("Adoptable: true")
    visit "/pets/#{@lucille.id}"
    expect(page).to have_content("Adoptable: true")

    visit "/admin/applications/#{@appl_2.id}"

    within("#pet-#{@moody.id}") do
      click_button "Approve"

      expect(page).to have_content("Pet has been approved!")
    end
    expect(@moody.adoptable).to be(true)
    expect(@lucille.adoptable).to be(true)

    within("#pet-#{@lucille.id}") do
      click_button "Approve"

      expect(page).to have_content("Pet has been approved!")
    end
    visit "/pets/#{@moody.id}"
    expect(page).to have_content("Adoptable: false")
    # expect(@moody.adoptable).to be(false)
    visit "/pets/#{@lucille.id}"
    expect(page).to have_content("Adoptable: false")
    # expect(@lucille.adoptable).to be(false)
  end

  it 'displays unadoptability message on other pending applications for the same pet' do
    visit "/admin/applications/#{@appl_3.id}"

    within("#pet-#{@moody.id}") do
      click_button "Approve"

      expect(page).to have_content("Pet has been approved!")
    end

    visit "/admin/applications/#{@appl_2.id}"

    within("#pet-#{@moody.id}") do
      click_button "Approve"

      expect(page).to have_content("Pet has been approved!")
    end

    within("#pet-#{@lucille.id}") do
      click_button "Approve"

      expect(page).to have_content("Pet has been approved!")
    end

    expect(page).to have_content("Appliction status:Approved")

    visit "/admin/applications/#{@appl_3.id}"

    within("#pet-#{@moody.id}") do
      expect(page).to have_content("This pet has already been approved for adoption")
      expect(page).to have_button("Reject")
      expect(page).not_to have_button("Approve")
    end
  end

end
