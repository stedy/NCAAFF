import sqlite3
import time
from werkzeug import check_password_hash, generate_password_hash
from datetime import datetime
from flask import Flask, request, session, g, redirect, url_for \
        , abort, render_template, flash

from contextlib import closing

DEBUG = True
DATABASE = '/home/zachs/NCAAFF/site/ncaaff.db'
SECRET_KEY = 'development key'

app = Flask(__name__)
app.config.from_object(__name__)

app.config.from_envvar('NCAAFF_DB_SETTINGS', silent = True)

def connect_db():
    """Returns a new connection to the database"""
    return sqlite3.connect(app.config['DATABASE'])

def init_db():
    with closing(connect_db()) as db:
        with app.open_resource('schema.sql') as f:
            db.cursor().executescript(f.read())
        db.commit()

def query_db(query, args=(), one = False):
	"""Queries the database and returns a list of dictionaries"""
	cur = g.db.execute(query, args)
	rv = [dict((cur.description[idx][0], value)
		for idx, value in enumerate(row)) for row in cur.fetchall()]
	return (rv[0] if rv else None) if one else rv

@app.before_request
def before_request():
    g.db = connect_db()

@app.teardown_request
def teardown_request(exception):
    if hasattr(g, 'db'):
        g.db.close()


@app.route('/', methods = ['GET', 'POST'])
def start():
    error = None
    entries = query_db("""select picker, score from standings""", one = False)
    return render_template('standings.html', error = error, entries = entries)
 
@app.route('/query', methods = ['GET', 'POST'])
def query():
	return render_template('query.html')

@app.route('/all_conferences', methods = ['GET', 'POST'])
def all_conferences():
    entries = query_db("""select conference, picker, school, conf, overall, confpercent, points from allconf""", one = False)
    acc = query_db("""SELECT conference, picker, school, conf, overall, 
            confpercent, points from allconf WHERE conference = 'ACC'""", one = False)
    american = query_db("""SELECT conference, picker, school, conf, overall, 
            confpercent, points from allconf WHERE conference = 'American'""", one = False)
    cusa = query_db("""SELECT conference, picker, school, conf, overall, 
            confpercent, points from allconf WHERE conference = 'Conference USA'""", one = False)
    mwc = query_db("""SELECT conference, picker, school, conf, overall, 
            confpercent, points from allconf WHERE conference = 'MWC'""", one = False)
    mac = query_db("""SELECT conference, picker, school, conf, overall, 
            confpercent, points from allconf WHERE conference = 'MAC'""", one = False)
    big12 = query_db("""SELECT conference, picker, school, conf, overall, 
            confpercent, points from allconf WHERE conference = 'Big 12'""", one = False)
    big10 = query_db("""SELECT conference, picker, school, conf, overall, 
            confpercent, points from allconf WHERE conference = 'Big Ten'""", one = False)
    pac12 = query_db("""SELECT conference, picker, school, conf, overall, 
            confpercent, points from allconf WHERE conference = 'Pac-12'""", one = False)
    sec = query_db("""SELECT conference, picker, school, conf, overall, 
            confpercent, points from allconf WHERE conference = 'SEC'""", one = False)
    sunbelt = query_db("""SELECT conference, picker, school, conf, overall, 
            confpercent, points from allconf WHERE conference = 'Sun Belt'""", one = False)
    return render_template('all_conferences.html', entries = entries,
            acc=acc, american=american, cusa=cusa, mwc=mwc, big12=big12,
            mac=mac, big10=big10, pac12 = pac12, sec=sec, sunbelt=sunbelt)


@app.route('/query_results', methods = ['GET', 'POST'])
def query_results():
    error = None
    if request.form['Indiv1'] == request.form['Indiv2']:
        error = " You can't compare someone to themselves"
        return render_template('query.html', error = error)
    else: 
        #request.form['Indiv1'] and request.form['Indiv2']:
        dbname = str(request.form['Indiv1']) + "_" + str(request.form['Indiv2'])
        entries = query_db("""select Home, Away, Homescore, Awayscore, Date, Datestr, picks1, picks2, indiv1, indiv2 
                from %s""" % dbname, one = False)
        return render_template('query_results.html', entries = entries)

@app.route('/<name>')
def name_results(name):
    entries = query_db("""select Team, Conf, Picker from picks where Picker == ?""", [name], one = False)
    return render_template('name.html', entries = entries)

@app.route('/Mark')
def mark():
    return render_template('Mark.html')

if __name__ == '__main__':
    app.run()
