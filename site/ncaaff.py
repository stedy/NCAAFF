import sqlite3
from flask import Flask, g, render_template
from contextlib import closing

DATABASE = '/home/zachs/NCAAFF/site/ncaaff.db'

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
    """Main start page showing snapshot of standings"""
    entries = query_db("""select picker, score FROM standings""", one = False)
    return render_template('standings.html', entries = entries)

@app.route('/all_conferences', methods = ['GET', 'POST'])
def all_conferences():
    """Show results and points for all conferences"""
    entries = query_db("""select conference, picker, school, conf, overall,
            confpercent, points FROM allconf""", one = False)
    acc = query_db("""SELECT conference, picker, school, conf, overall,
            confpercent, points FROM allconf WHERE conference = 'ACC'""",
            one = False)
    american = query_db("""SELECT conference, picker, school, conf, overall,
            confpercent, points FROM allconf WHERE conference = 'American'""",
            one = False)
    big10 = query_db("""SELECT conference, picker, school, conf, overall,
            confpercent, points FROM allconf WHERE conference = 'Big Ten'""",
            one = False)
    big12 = query_db("""SELECT conference, picker, school, conf, overall,
            confpercent, points FROM allconf WHERE conference = 'Big 12'""",
            one = False)
    cusa = query_db("""SELECT conference, picker, school, conf, overall,
            confpercent, points FROM allconf WHERE
            conference = 'Conference USA'""", one = False)
    mwc = query_db("""SELECT conference, picker, school, conf, overall,
            confpercent, points FROM allconf WHERE conference = 'MWC'""",
            one = False)
    mac = query_db("""SELECT conference, picker, school, conf, overall,
            confpercent, points FROM allconf WHERE conference = 'MAC'""",
            one = False)
    pac12 = query_db("""SELECT conference, picker, school, conf, overall,
            confpercent, points FROM allconf WHERE conference = 'Pac-12'""",
            one = False)
    sec = query_db("""SELECT conference, picker, school, conf, overall,
            confpercent, points FROM allconf WHERE conference = 'SEC'""",
            one = False)
    sunbelt = query_db("""SELECT conference, picker, school, conf, overall,
            confpercent, points FROM allconf WHERE conference = 'Sun Belt'""",
            one = False)
    return render_template('all_conferences.html', entries = entries,
            acc=acc, american=american, cusa=cusa, mwc=mwc, big12=big12,
            mac=mac, big10=big10, pac12 = pac12, sec=sec, sunbelt=sunbelt)

@app.route('/<name>')
def name_results(name):
    """View results of an individual person"""
    pickerentries = query_db("""select Team, Conf, Picker FROM picks
            WHERE Picker == ?""", [name], one = False)
    assert len(pickerentries) == 13
    return render_template('name.html', pickerentries = pickerentries)

@app.route('/Mark')
def mark():
    """Mark bailed on this season so be sure to make fun of him"""
    return render_template('Mark.html')

if __name__ == '__main__':
    app.run()
