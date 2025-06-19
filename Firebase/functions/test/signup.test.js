const assert = require('node:assert');
const test = require('node:test');
const admin = require('firebase-admin');

const { createTeamCreateUser } = require('../lib/signup/createTeamCreateUser');
const { joinTeamCreateUser } = require('../lib/signup/joinTeamCreateUser');

test('createTeamCreateUser success', async () => {
  const originalFirestore = admin.firestore;
  let teamSet = false;
  let userSet = false;

  const userDoc = { set: async () => { userSet = true; } };
  const teamDoc = {
    id: 'team123',
    set: async () => { teamSet = true; },
    collection: () => ({ doc: () => userDoc })
  };

  const firestore = { collection: () => ({ doc: () => teamDoc }) };
  admin.firestore = () => firestore;

  const res = await createTeamCreateUser({
    data: { teamName: 'Team', displayName: 'User', email: 'a@b.com' },
    auth: { uid: 'user1' }
  });

  assert.strictEqual(res.teamId, 'team123');
  assert.equal(res.teamCode.length, 6);
  assert.ok(teamSet);
  assert.ok(userSet);

  admin.firestore = originalFirestore;
});

test('createTeamCreateUser missing auth throws', async () => {
  let error;
  try {
    await createTeamCreateUser({ data: {} });
  } catch (e) {
    error = e;
  }
  assert.ok(error instanceof Error);
});

test('joinTeamCreateUser success', async () => {
  const originalFirestore = admin.firestore;
  let userSet = false;

  const userDoc = {
    get: async () => ({ exists: false }),
    set: async () => { userSet = true; }
  };
  const teamDoc = { id: 'team1', ref: { collection: () => ({ doc: () => userDoc }) } };

  const firestore = {
    collection: () => ({
      get: async () => ({ docs: [teamDoc] }),
      where: () => ({ get: async () => ({ empty: false, docs: [teamDoc] }) })
    })
  };
  admin.firestore = () => firestore;

  const res = await joinTeamCreateUser({
    data: { teamCode: 'code', displayName: 'User' },
    auth: { uid: 'user1' }
  });

  assert.strictEqual(res.teamId, 'team1');
  assert.ok(userSet);
  admin.firestore = originalFirestore;
});

test('joinTeamCreateUser missing team throws', async () => {
  const originalFirestore = admin.firestore;
  const firestore = {
    collection: () => ({
      get: async () => ({ docs: [] }),
      where: () => ({ get: async () => ({ empty: true }) })
    })
  };
  admin.firestore = () => firestore;

  let error;
  try {
    await joinTeamCreateUser({
      data: { teamCode: 'bad', displayName: 'User' },
      auth: { uid: 'user1' }
    });
  } catch (e) {
    error = e;
  }

  assert.ok(error instanceof Error);
  admin.firestore = originalFirestore;
});
