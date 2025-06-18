import * as admin from "firebase-admin";
import { randomBytes } from "crypto";
import { expect } from "chai";
import sinon from "sinon";
import * as functionsTest from "firebase-functions-test";

import { createTeamCreateUser } from "../src/signup/createTeamCreateUser";
import { joinTeamCreateUser } from "../src/signup/joinTeamCreateUser";

const test = functionsTest();

describe("signup functions", () => {
  afterEach(() => {
    sinon.restore();
    test.cleanup();
  });

  it("createTeamCreateUser success", async () => {
    const firestore: any = { collection: sinon.stub() };
    sinon.stub(admin, "firestore").returns(firestore);

    const usersCol = { doc: sinon.stub() };
    const userDoc = { set: sinon.stub().resolves() };
    usersCol.doc.withArgs("user1").returns(userDoc);

    const teamDoc = {
      id: "team123",
      set: sinon.stub().resolves(),
      collection: sinon.stub().withArgs("users").returns(usersCol),
    };
    firestore.collection.withArgs("teams").returns({ doc: sinon.stub().returns(teamDoc) });

    sinon.stub(randomBytes as any, "call").returns(Buffer.from("abcdef", "hex"));

    const wrapped = test.wrap(createTeamCreateUser);
    const result = await wrapped({
      data: { teamName: "Test Team", displayName: "User", email: "a@b.com" },
      auth: { uid: "user1" },
    });

    expect(result.teamId).to.equal("team123");
    expect(result.teamCode).to.equal("ABCDEF");
    expect(teamDoc.set.calledOnce).to.be.true;
    expect(userDoc.set.calledOnce).to.be.true;
  });

  it("createTeamCreateUser missing auth throws", async () => {
    const wrapped = test.wrap(createTeamCreateUser);
    let error: any = null;
    try {
      await wrapped({ data: {}, auth: undefined } as any);
    } catch (err) {
      error = err;
    }
    expect(error).to.be.instanceOf(Error);
  });

  it("joinTeamCreateUser success", async () => {
    const firestore: any = { collection: sinon.stub() };
    sinon.stub(admin, "firestore").returns(firestore);

    const userDoc = { get: sinon.stub().resolves({ exists: false }), set: sinon.stub().resolves() };
    const usersCol = { doc: sinon.stub().returns(userDoc) };

    const teamDoc = { id: "team1", ref: { collection: sinon.stub().withArgs("users").returns(usersCol) } };
    firestore.collection
      .withArgs("teams")
      .onFirstCall()
      .returns({ get: sinon.stub().resolves({ docs: [teamDoc] }) })
      .onSecondCall()
      .returns({ where: sinon.stub().withArgs("teamCode", "==", "CODE").returns({ get: sinon.stub().resolves({ empty: false, docs: [teamDoc] }) }) });

    const wrapped = test.wrap(joinTeamCreateUser);
    const res = await wrapped({ data: { teamCode: "code", displayName: "User" }, auth: { uid: "user1" } });

    expect(res.teamId).to.equal("team1");
    expect(userDoc.set.calledOnce).to.be.true;
  });

  it("joinTeamCreateUser missing team throws", async () => {
    const firestore: any = { collection: sinon.stub() };
    sinon.stub(admin, "firestore").returns(firestore);

    firestore.collection
      .withArgs("teams")
      .onFirstCall()
      .returns({ get: sinon.stub().resolves({ docs: [] }) })
      .onSecondCall()
      .returns({ where: sinon.stub().withArgs("teamCode", "==", "BAD").returns({ get: sinon.stub().resolves({ empty: true }) }) });

    const wrapped = test.wrap(joinTeamCreateUser);
    let error: any = null;
    try {
      await wrapped({ data: { teamCode: "bad", displayName: "User" }, auth: { uid: "user1" } });
    } catch (err) {
      error = err;
    }
    expect(error).to.be.instanceOf(Error);
  });
});
