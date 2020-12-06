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


#db.create_all() # create database based on class definition


# @app.route('/')
# def index():
#     return redirect(url_for('get_list_teams', team_id=1))

@app.route('/owner/create', methods=['POST'])
def create_owner():
    error = False
    body = {}
    try:
        req = request.get_json()
        us = req['username']
        pw = req['password']
        team = Team(name="change this later", wins = 0, losses = 0, owner_id = 1, league_id = 1, player_ids = "")
        owner = Owner(username = us, password = pw, team_id = 1)
        #team.owner_id = owner.owner_id
        db.session.add(team)
        db.session.commit()
        db.session.add(owner)
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
