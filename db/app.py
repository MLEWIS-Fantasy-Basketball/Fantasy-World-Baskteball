from flask import Flask, render_template, request, redirect, url_for, jsonify, abort
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
import sys

app = Flask(__name__) 
# config the SQLAlchemy connection to the database as your own database

app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:Cocoa1@localhost:5432/Fantasy_Basketball'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app) 

migrate = Migrate(app, db)

class Team(db.Model):
    __tablename__ = 'team' # specify the table name if it is different from class name
    __table_args__ = {'extend_existing': True} 
    id = db.Column('team_id', db.Integer, primary_key=True)#db.Integer, primary_key=True) # define ID 
    owner_id = db.Column(db.Integer, nullable=False)
    name = db.Column(db.String(), nullable=False) # define description
    wins = db.Column(db.Integer, nullable=False)
    losses = db.Column(db.Integer, nullable=False)
    player_ids = db.Column(db.String(), nullable=False)
    #completed = db.Column(db.Boolean, nullable=False, default=False)
    #team_id = db.Column(db.Integer, db.ForeignKey('team.team_id'), nullable=False)

    # for debug print object information purpose
    def __repr__(self):
        return f'<Team: ID {self.id}, description {self.description}>'


class Player(db.Model):
    __tablename__ = 'player' # specify the table name if it is different from class name
    __table_args__ = {'extend_existing': True} 
    id = db.Column('player_id', db.Integer, primary_key=True) # define ID 
    name = db.Column(db.String(), nullable=False) # define description
    on_team = db.Column(db.Boolean, nullable=False)
    position = db.Column(db.String(), nullable=False)
    real_team_name = db.Column(db.String(), nullable=False)
    real_league_name = db.Column(db.String(), nullable=False)
    #completed = db.Column(db.Boolean, nullable=False, default=False)
    #player_id = db.Column(db.Integer, db.ForeignKey('player.player_id'), nullable=False)

    # for debug print object information purpose
    def __repr__(self):
        return f'<Player: ID {self.id}, description {self.description}>'



#db.create_all() # create database based on class definition


@app.route('/')
def index():
    return redirect(url_for('get_list_teams', team_id=1))

@app.route('/lists/<team_id>') # tell Flask what URL should trigger the function
# the function is given a name which is used to generate URLs for that particular function and returns the message we want to display in browser, function name does not matter
def get_list_teams(team_id):
    
    teams = Team.query.filter_by(id=team_id).order_by('team_id').all()
    
    return render_template('index.html',teams=teams)

@app.route('/lists/create', methods=['POST'])
def create_team():
    error = False
    body = {}
    try:
        name = request.get_json()['name']
        if not name:
            name = 'Causal'
        team = Team(name=name)
        db.session.add(team)
        db.session.commit()
        #body['team_id'] = teamlist.id
        #body['name'] = teamlist.name
    except:
        error = True
        db.session.rollback()
        print(sys.exc_info())
    finally:
        db.session.close()
    if error:
        abort(400)
    else:
        return jsonify(body)


@app.route('/Team/<team_id>/delete', methods=['DELETE'])
def delete_team(team_id):
    error = False
    try:
        Team.query.filter_by(id=team_id).delete()
        db.session.commit()
    except:
        db.session.rollback()
        error = True
    finally:
        db.session.close()
    if error:
        abort(400)
    else:
        return jsonify({'success': True})


@app.route('/')
def PlayersIndex():
    return redirect(url_for('get_list_players', list_id=1))

@app.route('/lists/<list_id>') # tell Flask what URL should trigger the function
# the function is given a name which is used to generate URLs for that particular function and returns the message we want to display in browser, function name does not matter
def get_list_players(list_id):
    
    players = Player.query.filter_by(id=list_id).order_by('player_id').all()
    
    return render_template('index.html',players=players)

@app.route('/lists/create', methods=['POST'])
def create_player():
    error = False
    body = {}
    try:
        name = request.get_json()['name']
        if not name:
            name = 'Causal'
        playerlist = PlayerList(name=name)
        db.session.add(playerlist)
        db.session.commit()
        #body['player_id'] = playerlist.id
        #body['name'] = playerlist.name
    except:
        error = True
        db.session.rollback()
        print(sys.exc_info())
    finally:
        db.session.close()
    if error:
        abort(400)
    else:
        return jsonify(body)


@app.route('/Player/<Player_id>/delete', methods=['DELETE'])
def delete_player(player_id):
    error = False
    try:
        Player.query.filter_by(id=player_id).delete()
        db.session.commit()
    except:
        db.session.rollback()
        error = True
    finally:
        db.session.close()
    if error:
        abort(400)
    else:
        return jsonify({'success': True})

