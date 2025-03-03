require "application_system_test_case"

class PracticalSupportBehaviorsTest < ApplicationSystemTestCase
  before do
    @user = create :user
    @patient = create :patient, line: 'DC'
  end

  describe 'creating a new practical support entry' do
    before { go_to_practical_support_tab }

    it 'should start empty' do
      within :css, '#existing-practical-supports' do
        assert has_no_text? 'Category of support'
        assert has_no_selector? '#practical_support_support_type'
      end
    end

    it 'should log a new practical support' do
      within :css, '#practical-support-new-form' do
        select 'Companion', from: 'practical_support_support_type'
        select 'Other funds (see notes)', from: 'practical_support_source'
        check 'Confirmed'
        click_button 'Create new practical support'
      end

      within :css, '#existing-practical-supports' do
        assert_equal 'companion', find('#practical_support_support_type').value
        assert_equal 'Other funds (see notes)', find('#practical_support_source').value
        assert has_checked_field? 'Confirmed'
      end
    end

    it 'should fail with a message on failed create' do
      # Leaving support_type blank should do it!
      within :css, '#practical-support-new-form' do
        click_button 'Create new practical support'
      end

      assert has_text? "Practical support failed to save: Support type can't be blank"

      within :css, '#existing-practical-supports' do
        assert has_no_selector? '#practical_support_support_type'
      end
    end
  end

  describe 'updating practical support entries' do
    before do
      @patient.practical_supports.create support_type: 'lodging',
                                         source: 'Other funds (see notes)',
                                         created_by: @user

                                        # binding.pry
      go_to_practical_support_tab
    end

    it 'should save if valid and changed' do
      within :css, '#existing-practical-supports' do
        select 'Companion', from: 'practical_support_support_type'
        select 'Clinic discount', from: 'practical_support_source'
        check 'Confirmed'
      end

      assert has_text? "Patient info successfully saved"

      reload_page_and_click_link 'Practical Support'
      within :css, '#existing-practical-supports' do
        assert_equal 'companion', find('#practical_support_support_type').value
        assert_equal 'Clinic discount', find('#practical_support_source').value
        assert has_checked_field? 'Confirmed'
      end
    end

    it 'should fail if changed to invalid' do
      within :css, '#existing-practical-supports' do
        select '', from: 'practical_support_support_type'
      end

      assert has_text? "Practical support failed to save: Support type can't be blank"

      reload_page_and_click_link 'Practical Support'
      within :css, '#existing-practical-supports' do
        assert_equal 'lodging', find('#practical_support_support_type').value
      end
    end
  end

  describe 'destroying a practical support entry' do
    before do
      @patient.practical_supports.create support_type: 'lodging',
                                         source: 'Other funds (see notes)',
                                         created_by: @user
      go_to_practical_support_tab
    end

    it 'destroy practical supports if you click the big red button' do
      within :css, '#existing-practical-supports' do 
        accept_confirm { click_button 'Delete' }
      end

      reload_page_and_click_link 'Practical Support'
      within :css, '#existing-practical-supports' do
        assert has_no_selector? '#practical_support_support_type'
      end
    end
  end
end

def go_to_practical_support_tab
  log_in_as @user
  visit edit_patient_path @patient
  has_text? 'First and last name' # wait for element
  click_link 'Practical Support'
end

def reload_page_and_click_link(link_text)
  click_away_from_field
  visit authenticated_root_path
  visit edit_patient_path @patient
  click_link link_text
end
