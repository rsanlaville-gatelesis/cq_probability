import pandas as pd 
from snowflake.connector.pandas_tools import write_pandas
from snowflake.connector import connect
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.naive_bayes import GaussianNB
from sklearn.linear_model import Perceptron
from sklearn.tree import DecisionTreeClassifier
from sklearn.svm import LinearSVC

# connect to db
ctx = connect ( 
user = 'SAHILRATNAM', 
password = 'C@t567328', 
account = 'qr93446.east-us-2.azure',
database = 'CLA_PROD'
) 

# pull data
query = open('MLquery.sql', 'r').read()
cq = ctx.cursor()
cq.execute(query)
df = pd.DataFrame.from_records(iter(cq), columns=[x[0] for x in cq.description])
df_o = df[df['STATUS_TYPE'] == 'Open'].copy()
df_c = df[df['STATUS_TYPE'] == 'Closed'].copy()
cq.close()
ctx.close()

# prep data for model
y = df_c['IS_SOLD']
X = df_c.drop(['CQD_AUTO_KEY','STATUS_TYPE','IS_SOLD'], axis=1)
df_o_ = df_o.drop(['CQD_AUTO_KEY','STATUS_TYPE','IS_SOLD'], axis=1)


# Log Reg
logreg = LogisticRegression(solver='lbfgs', multi_class='multinomial')
logreg.fit(X, y)
df_o['log_reg'] = logreg.predict_proba(df_o_)[:, 1]


# Random Forest
random_forest = RandomForestClassifier(n_estimators=100)
random_forest.fit(X, y)
df_o['random_forest'] = random_forest.predict_proba(df_o_)[:, 1]


# Gaussian
gaussian = GaussianNB()
gaussian.fit(X, y)
df_o['gaussian'] = gaussian.predict_proba(df_o_)[:, 1]


# Perceptron
perceptron = Perceptron()
perceptron.fit(X, y)
df_o['perceptron'] = perceptron._predict_proba_lr(df_o_)[:, 1]


# Decision Tree
decision_tree = DecisionTreeClassifier()
decision_tree.fit(X, y)
df_o["decision_tree"] = decision_tree.predict_proba(df_o_)[:, 1]


# Linear SVC
linear_svc = LinearSVC()
linear_svc.fit(X, y)
df_o['lin_SVC'] = linear_svc._predict_proba_lr(df_o_)[:, 1]


df_o['CONVERSION_PROBABILITY'] = df_o[['log_reg','random_forest','gaussian','perceptron','decision_tree','lin_SVC']].mean(axis=1)
# df_o.to_csv('final.csv', index = False)

# reopen connection and upload df to snowflake db
conn = connect(
    user = 'REMYSANLAVILLE',
    password = 'GATelesis001!',
    account = 'qr93446.east-us-2.azure',
    database = 'DW_TEST',
    schema = 'STAGING'
    )
success, nchunks, nrows, _ = write_pandas(conn, df_o[['CQD_AUTO_KEY','CONVERSION_PROBABILITY']], 'PYTHON_CQD_SUCCESS_QCTL', overwrite = True)
conn.close()