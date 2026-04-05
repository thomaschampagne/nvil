import { User } from "./models";

export class UserService {
  private users: User[] = [];

  addUser(user: User): void {
    this.users.push(user);
    console.log(`Added user: ${user.name}`);
  }

  listUsers(): void {
    console.log("Users:", this.users);
  }
}
