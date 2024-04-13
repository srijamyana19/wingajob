from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import pandas as pd
import os
from openpyxl import load_workbook
import win32com.client as win32
import re


app = Flask(__name__)
CORS(app)

type = ''
startDate = ''
endDate = ''
location = ''
keywords = ''

@app.route('/submit', methods=['POST'])
def submit():
    print("I'm outside if")
    if request.method == 'POST':
        data = request.json
        print('Received JSON data:', data)
        response = {'message': 'Data received successfully'}
        type = data['jobType']
        startDate = data['startDate']
        endDate = data['endDate']
        location = data['location']
        keywords = data['jobKeywords']
        #print('type is: {} - start date: {} - end date: {} - location: {} - keywods: {}'.format(type, startDate, endDate, location, keywords))

        # url = "http://api.adzuna.com:80/v1/api/jobs/gb/search/1?app_id=9aa952c0&app_key=5643af22fbfb3437a32a1294d756d49b&results_per_page=20&what=javascript%20developer&what_exclude=java&where=UK&sort_by=salary&salary_min=30000&full_time=1&permanent=1&content-type=application/json"
        url = "http://api.adzuna.com:80/v1/api/jobs/gb/search/1?app_id=9aa952c0&app_key=5643af22fbfb3437a32a1294d756d49b&results_per_page=20&what={}&what_exclude=java&where={}&sort_by=salary&salary_min=30000&full_time={}&permanent=1&content-type=application/json".format(keywords, location, type)
        payload = {}
        headers = {
        'Authorization': 'Basic U3dhcG5hMTQ6UXdlcnR5QDE0MTA='
        }

        response = requests.request("GET", url, headers=headers, data=payload)
        df = pd.DataFrame()

        data = response.json()

        tech_stack_keywords = ['Python', 'Django', 'React', 'Excel', 'SQL', 'Linux', 'Docker', 'Servicenow', 'Full Stack','AWS', 'Java', 'C++', 'JavaScript', 'Angular', 'NodeJs', 'Salesforce', 'HTML', 'CSS', 'Kubernetes', 'Terraform', 'Ruby', 'Flask', 'Spring Boot', 'Swift', 'Kotlin', 'TypeScript', 'Vue.js', 'GraphQL', 'Redux', 'RESTful API', 'MongoDB', 'PostgreSQL', 'Oracle', 'Firebase', 'CI/CD', 'Jenkins', 'Git', 'Agile', 'Scrum', 'DevOps', 'Machine Learning', '.NET','Artificial Intelligence', 'Big Data', 'Data Science', 'Elasticsearch', 'Logstash', 'Kibana', 'Splunk', 'RabbitMQ', 'Nginx', 'Apache']


        def extract_keywords(description):
            keywords = []
            for keyword in tech_stack_keywords:
                pattern = r'\b{}\b'.format(re.escape(keyword))
                if re.search(pattern, description, re.IGNORECASE):
                    keywords.append(keyword)
            return ', '.join(keywords)

        selected_fields = [
            {
                'id': item.get('id'),
                'company_name': item['company'].get('display_name'),
                'title': item.get('title'),
                'location': item['location'].get('display_name'),
                'description': item.get('description', ''),  
                'redirect_url': item.get('redirect_url')
            }
            for item in data.get('results', [])
        ]

        new_df = pd.DataFrame(selected_fields)
        new_df['Tech Stack'] = new_df['description'].apply(extract_keywords)

        new_df = new_df.drop(columns=['description'])

        file_path = '/Downloads/example.xlsx'

        if os.path.exists(file_path):
                old_df = pd.read_excel(file_path)
                df = pd.concat([old_df, new_df], ignore_index=True)
        else:
            df = new_df
                
        length1 = len(df)
        df['status'] = ['no'] * length1

        if(url in df['redirect_url'].values):
            row_index = df[df['redirect_url'] == url].index[0]
            df.at[row_index, 'status'] = "yes"
            
        df.to_excel(file_path, index=False)

        print("Data has been processed and saved to Excel.")


        if os.path.exists(file_path):

            try:
                excel = win32.gencache.EnsureDispatch('Excel.Application')
                wb = excel.Workbooks.Open(file_path)
                ws = wb.Worksheets("Sheet1")
                ws.Columns.AutoFit()
                wb.Save()
                excel.Application.Quit()
                print("File opened successfully.")
            except Exception as e:
                print(f"Error opening file: {e}")

        # return jsonify(response)

if __name__ == '__main__':
    app.run(debug=False)