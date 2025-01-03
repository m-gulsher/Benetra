# README Carefully

Overview:
The Insurance Management Platform streamlines the relationship between health insurance companies, brokers, HR representatives, and employees. It offers tools for managing policies, employee enrollments, and communications with a focus on efficiency and ease of use.

Prerequisites:

-> Ruby Version:
1.Ruby 3.2.4

-> Rails Version:
1.Rails 8.0.0

-> System Dependencies 
1. PostgreSQL 
2. Yarn (for package management)

Setup Instructions:

-> Clone Repository using these steps: 

  1. git clone https://github.com/m-gulsher/ichra_assesment.git 
  2. cd ichra_assesment

-> Install the necessary dependencies: 

  1. bundle install 
  2. yarn install

-> Set up the Database: 

  1. rails db:create 
  2. rails db:migrate 
  3. rails db:seed

-> Start the Server: 

  1. bin/dev

-> After running the server, access the application at http://localhost:3000

Code Architecture:

The platform follows a modular structure with clear distinctions for roles and responsibilities:

Models and Relationships

-> Admin, Employee, Agent, and User Models:

1.Admin, Employee, and Agent models inherit authentication capabilities through polymorphic associations with the User model

2.Each model (Admin, Employee, Agent) has unique validation logic and uses the after_create callback to ensure proper associations with User.

-> Agency and Company Models:
  1.Agencies manage multiple Agents, while Companies manage Employees and Policies. 
  2. Policies link a Company with an Agent. 
  3. Implements authentication using Devise. 
  4. Supports roles (admin, agent, employee) with role-based validations and associations

Authentication

-> Devise is implemented for user authentication, providing modules like: database_authenticatable, registerable, recoverable, rememberable, validatable

Frontend Integration

  1.TailwindCSS: Used for streamlined and modern frontend styling.
  2.StimulusJS: JavaScript functionality for enhanced user interaction, particularly for table operations.

Note: 

To use employee importer please user sample csv place here: "app/assets/sample_employees.csv"

## Thanks ##