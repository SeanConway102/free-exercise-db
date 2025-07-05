import { promises as fs } from 'fs';
import path from 'path';

const projectDir = process.cwd();
const generalDir = path.join(projectDir, 'general_exercises');
const exercisesDir = path.join(projectDir, 'exercises');
const distDir = path.join(projectDir, 'dist');

async function main() {
  const files = await fs.readdir(generalDir);
  let combined = [];
  for (const file of files) {
    if (!file.endsWith('.json')) continue;
    const fullPath = path.join(generalDir, file);
    const data = JSON.parse(await fs.readFile(fullPath, 'utf8'));
    if (!Array.isArray(data.variations)) continue;
    for (const variation of data.variations) {
      const destFile = path.join(exercisesDir, `${variation.id}.json`);
      await fs.writeFile(destFile, JSON.stringify(variation, null, 2) + '\n');
      combined.push(variation);
    }
  }
  await fs.mkdir(distDir, { recursive: true });
  await fs.writeFile(
    path.join(distDir, 'exercises.json'),
    JSON.stringify(combined, null, 2) + '\n'
  );
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
