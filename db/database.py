import psycopg2
import pandas as pd
import hashlib

user = "<fill in user>"

try: 
    conn = psycopg2.connect("dbname = fantasy_basketball user = " + user)

except:
    print("Could not open connection.")

df = pd.read_csv('/Fantasy-World-Baskteball/db/players_stats_by_season_full_details.csv', header = 0)

playerInfo = df.drop_duplicates(('League', 'Player'))[['League','Player','Team','height_cm']].to_numpy()

playerTableInfo = []

for line in playerInfo:
    pos = ''
    height = line[3]
    if height < 198:
        pos = 'G'
    elif height > 209:
        pos = 'C'
    else:
        pos = 'F'
        
    ret = [line[1], False, pos, line[2], line[0]]
    playerTableInfo.append(ret)
    
# print(playerTableInfo)


mycursor = conn.cursor()
    
sql = "INSERT INTO public.player (name, on_team, position, real_team_name, real_league_name) VALUES (%s, %s, %s, %s, %s)"
mycursor.executemany(sql, playerTableInfo)
conn.commit()

    
mycursor.execute("SELECT player_id,name,real_team_name,real_league_name FROM public.player")
playerIDData = mycursor.fetchall()
pIDDF = pd.DataFrame(playerIDData, columns = ['player_id','Player','Team','League'])
joinedData = pd.merge(df, pIDDF, on=['Player', 'Team', 'League'])


statDataCol = [col for col in list(joinedData.columns) if col not in ["Player","League","Team","high_school,birth_year,birth_month"]]
statData = joinedData.drop_duplicates(('Season','player_id'))[statDataCol].to_numpy()
statTableData = []

print(statData)

for line in statData:
    stats = ""
    season = int((line[0])[7:11])
    pID = int(line[len(line)-1])
    for i in line:
        stats += str(i) + ","
    for i in range (0,2):
        index = stats.index(',')+1
        lastIndex = stats.rindex(',')
        stats = stats[index:lastIndex]
    ret2 = [str(season) + '_' + str(pID),season,pID,stats,""]
    if line[1] == 'Regular_Season' or line[1] == 'International':
        statTableData.append(ret2)

sql = "INSERT INTO public.stats (year_player_key,year, player_id, real_stats, fantasy_stats) VALUES (%s,%s, %s, %s, %s)"
mycursor.executemany(sql, statTableData)
conn.commit()


mycursor.close()
conn.close()
print("PostgreSQL connection is closed")