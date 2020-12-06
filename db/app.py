from flask import Flask, render_template, request, redirect, url_for, jsonify, abort
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_cors import CORS
from pprint import pprint
import json
import sys

app = Flask(__name__)

CORS(app)
# config the SQLAlchemy connection to the database as your own database

app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:@localhost:5432/fantasy_basketball'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# migrate = Migrate(app, db)

class Team(db.Model):
    __tablename__ = 'team' # specify the table name if it is different from class name
    __table_args__ = {'extend_existing': True}
    id = db.Column('team_id', db.Integer, primary_key=True)#db.Integer, primary_key=True) # define ID
    owner_id = db.Column(db.Integer, nullable=False)
    name = db.Column(db.String(), nullable=False) # define description
    wins = db.Column(db.Integer, nullable=False)
    losses = db.Column(db.Integer, nullable=False)
    player_ids = db.Column(db.String(), nullable=False)
    league_id = db.Column(db.Integer, nullable=False)
    #completed = db.Column(db.Boolean, nullable=False, default=False)
    #team_id = db.Column(db.Integer, db.ForeignKey('team.team_id'), nullable=False)

    # for debug print object information purpose
    def __repr__(self):
        return f'<Team: ID {self.id}, description {self.description}>'

    def as_dict(self):
        attributes = dict()
        attributes['id'] = self.id
        attributes['owner_id'] = self.owner_id
        attributes['name'] = self.name
        attributes['wins'] = self.wins
        attributes['losses'] = self.loses
        attributes['player_ids'] = self.player_ids
        return attributes




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
        return f'<Player: ID {self.id}, description {self.name}>'

    def as_dict(self):
        attributes = dict()
        attributes['id'] = self.id
        attributes['name'] = self.name
        attributes['on_team'] = self.on_team
        attributes['position'] = self.position
        attributes['real_team_name'] = self.real_team_name
        attributes['real_league_name'] = self.real_league_name
        return attributes

class Owner(db.Model):
    __tablename__ = 'owner' # specify the table name if it is different from class name
    __table_args__ = {'extend_existing': True}
    owner_id = db.Column('owner_id', db.Integer, primary_key=True) # define ID
    team_id = db.Column('team_id', db.Integer)
    username = db.Column(db.String(), nullable=False) # define description
    password = db.Column(db.String(), nullable=False)

    # for debug print object information purpose
    def __repr__(self):
        return f'<Player: ID {self.id}, description {self.username}>'

class League(db.Model):
    __tablename__ = 'league' # specify the table name if it is different from class name
    __table_args__ = {'extend_existing': True}
    league_id = db.Column(db.Integer, primary_key=True) # define ID
    commissioner_id = db.Column(db.Integer, nullable=False)
    league_name= db.Column(db.String(), nullable=False) # define description
    number_of_teams = db.Column(db.Integer, nullable=False)
    teams_ids = db.Column(db.String())

    # for debug print object information purpose
    def __repr__(self):
        return f'<Player: ID {self.id}, description {self.username}>'

    def as_dict(self):
        attributes = dict()
        attributes['league_id'] = self.league_id
        attributes['commissioner_id'] = self.commissioner_id
        attributes['league_name'] = self.league_name
        attributes['number_of_teams'] = self.number_of_teams
        attributes['teams_ids'] = self.teams_ids
        attributes['cname'] = Owner.query.get(self.commissioner_id).username
        return attributes


#db.create_all() # create database based on class definition


# @app.route('/')
# def index():
#     return redirect(url_for('get_list_teams', team_id=1))

@app.route('/league/create', methods=['POST'])
def create_league():
    error = False
    body = {}
    try:
        req = request.get_json()
        us = req['username']
        pw = req['password']
        tn = req['team_name']
        name = req['league_name']
        num_teams = int(req['number_of_teams'])
        owner = Owner(username = us, password = pw, team_id = 1)
        db.session.add(owner)
        db.session.commit()
        league = League(league_name = name, number_of_teams = num_teams, commissioner_id = owner.owner_id, teams_ids = "1")
        db.session.add(league)
        db.session.commit()
        team = Team(name = tn, wins = 0, losses = 0, owner_id = owner.owner_id, league_id = league.league_id, player_ids = "")
        db.session.add(team)
        db.session.commit()
        owner.team_id = team.id
        db.session.commit()
        league.teams_ids = team.id + ","
        db.session.commit()
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

@app.route('/owner/create', methods=['POST'])
def create_owner():
    error = False
    body = {}
    try:
        req = request.get_json()
        us = req['username']
        pw = req['password']
        tn = req['team_name']
        li = req['league_id']
        owner = Owner(username = us, password = pw, team_id = 1)
        db.session.add(owner)
        db.session.commit()
        team = Team(name = tn, wins = 0, losses = 0, owner_id = owner.owner_id, league_id = li, player_ids = "")
        db.session.add(team)
        db.session.commit()
        owner.team_id = team.id
        db.session.commit()
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

@app.route('/leaguelist', methods=['GET']) # tell Flask what URL should trigger the function
# the function is given a name which is used to generate URLs for that particular function and returns the message we want to display in browser, function name does not matter
def get_list_leagues():
    leagues = League.query.order_by('league_id').all()
    leagues_as_dicts = []
    for l in leagues:
         leagues_as_dicts.append(l.as_dict())
    return (jsonify(leagues_as_dicts))

@app.route('/teamlists/<team_id>') # tell Flask what URL should trigger the function
# the function is given a name which is used to generate URLs for that particular function and returns the message we want to display in browser, function name does not matter
def get_list_teams(team_id):

    teams = Team.query.filter_by(id=team_id).order_by('team_id').all()

    return jsonify(teams)

@app.route('/teamlists/create', methods=['POST'])
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


# @app.route('/', methods=['GET'])
# def PlayersIndex():
#     return redirect(url_for('get_list_players', list_id=1))


@app.route('/playerlists/<list_id>', methods=['GET']) # tell Flask what URL should trigger the function # the function is given a name which is used to generate URLs for that particular function and returns the message we want to display in browser, function name does not matter
def get_list_players(list_id):
    players = Player.query.order_by('player_id').all()
    players_as_dicts = []
    for p in players:
         players_as_dicts.append(p.as_dict())
    return (jsonify(players_as_dicts))

@app.route('/playerlists/create', methods=['POST'])
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
