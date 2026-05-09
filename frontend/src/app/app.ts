import { CommonModule } from '@angular/common';
import { HttpErrorResponse } from '@angular/common/http';
import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { ShortenerApiService } from './services/shortener-api.service';

@Component({
  selector: 'app-root',
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatButtonModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatSnackBarModule
  ],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {
  private readonly formBuilder = inject(FormBuilder);
  private readonly shortenerApi = inject(ShortenerApiService);
  private readonly snackBar = inject(MatSnackBar);

  protected readonly loading = signal(false);
  protected readonly shortLink = signal<string | null>(null);

  protected readonly form = this.formBuilder.nonNullable.group({
    originalLink: ['', [Validators.required, Validators.pattern('^(https?)://.+$')]]
  });

  protected submit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.loading.set(true);
    const originalLink = this.form.getRawValue().originalLink;
    this.shortenerApi.createShortLink({ originalLink }).subscribe({
      next: (response) => {
        this.shortLink.set(response.shortLink);
        this.loading.set(false);
      },
      error: (error: HttpErrorResponse) => {
        this.loading.set(false);
        this.shortLink.set(null);
        this.snackBar.open(error.error?.message ?? 'Could not shorten the URL right now.', 'Dismiss', {
          duration: 4000
        });
      }
    });
  }

  protected copyShortLink(): void {
    const link = this.shortLink();
    if (!link) {
      return;
    }

    navigator.clipboard.writeText(link).then(() => {
      this.snackBar.open('Short link copied.', 'Dismiss', { duration: 2500 });
    });
  }
}
