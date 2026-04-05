import { UserService } from './services';

const service = new UserService();
service.addUser({ id: 1, name: 'Alice', email: 'alice@example.com' });
service.addUser({ id: 2, name: 'Bob', email: 'bob@example.com' });
service.listUsers();